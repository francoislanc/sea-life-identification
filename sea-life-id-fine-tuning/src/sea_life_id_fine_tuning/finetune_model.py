import datetime
import json
import pickle
from pathlib import Path
from typing import List

import keras
import tensorflow as tf  # For tf.data
from keras import layers
from keras.applications import EfficientNetV2B0

# IMG_SIZE is determined by EfficientNet model choice
IMG_SIZE = 224
BATCH_SIZE = 64
TRAIN_MODEL = False
OUTPUT_FOLDER = Path(__file__).resolve().parent.parent.parent / "output"


def create_desired_metrics(
    desired_precisions,
    desired_recalls,
    desired_thresholds,
    class_id: int,
    name_suffix: str = "",
):
    """Creates desired metrics for model training."""
    metric_functions = []
    for desired_precision in desired_precisions:
        metric_functions.append(
            tf.keras.metrics.RecallAtPrecision(
                desired_precision,
                name=f"recall_at_precision_{desired_precision}{name_suffix}",
                num_thresholds=1000,
                class_id=class_id,
            )
        )
    for desired_recall in desired_recalls:
        metric_functions.append(
            tf.keras.metrics.PrecisionAtRecall(
                desired_recall,
                name=f"precision_at_recall_{desired_recall}{name_suffix}",
                num_thresholds=1000,
                class_id=class_id,
            )
        )
    for desired_threshold in desired_thresholds:
        metric_functions.append(
            tf.keras.metrics.Precision(
                thresholds=desired_threshold,
                name=f"p_at_{desired_threshold}{name_suffix}",
                class_id=class_id,
            )
        )
        metric_functions.append(
            tf.keras.metrics.Recall(
                thresholds=desired_threshold,
                name=f"r_at_{desired_threshold}{name_suffix}",
                class_id=class_id,
            )
        )
    return metric_functions


def build_model(num_classes: int, label_info: List[str]):
    inputs = layers.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
    model = EfficientNetV2B0(include_top=False, input_tensor=inputs, weights="imagenet")

    # Freeze the pretrained weights
    model.trainable = False

    # Rebuild top
    x = layers.GlobalAveragePooling2D(name="avg_pool")(model.output)
    x = layers.BatchNormalization()(x)

    top_dropout_rate = 0.2
    x = layers.Dropout(top_dropout_rate, name="top_dropout")(x)
    # outputs = layers.Dense(num_classes, activation="softmax", name="pred")(x)
    outputs = layers.Dense(num_classes, activation="sigmoid", name="pred")(x)

    # Compile
    model = keras.Model(inputs, outputs, name="EfficientNet")
    optimizer = keras.optimizers.Adam(learning_rate=1e-2)
    # model.compile(
    #     optimizer=optimizer, loss="categorical_crossentropy", metrics=["accuracy"]
    # )

    metric_functions = [
        tf.keras.metrics.BinaryAccuracy(),
        tf.keras.metrics.AUC(multi_label=True, num_labels=num_classes),
    ]
    for i in range(num_classes):
        metric_functions.extend(
            create_desired_metrics(
                [],
                [],
                [0.5],
                i,
                f"_{label_info[i]}",
            )
        )

    model.compile(
        optimizer=optimizer, loss="binary_crossentropy", metrics=metric_functions
    )
    return model


def run_finetuning(epochs: int):
    with open(str(OUTPUT_FOLDER / "datasets" / "multi_label_binarizer.pkl"), "rb") as f:
        mlb = pickle.load(f)
    ds_train_batch = tf.data.Dataset.load(
        str(OUTPUT_FOLDER / "datasets" / "ds_train_batch")
    )
    ds_test_batch = tf.data.Dataset.load(
        str(OUTPUT_FOLDER / "datasets" / "ds_test_batch")
    )

    label_info = list(mlb.classes_)
    NUM_CLASSES = len(label_info)

    model = build_model(num_classes=NUM_CLASSES, label_info=label_info)

    log_dir = (
        OUTPUT_FOLDER
        / "finetuning"
        / "logs"
        / "fit"
        / datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    )
    tensorboard_callback = tf.keras.callbacks.TensorBoard(
        log_dir=log_dir, histogram_freq=1
    )

    ds_train_no_path = ds_train_batch.map(lambda image, label, path: (image, label))
    ds_test_no_path = ds_test_batch.map(lambda image, label, path: (image, label))
    hist = model.fit(
        ds_train_no_path,
        epochs=epochs,
        validation_data=ds_test_no_path,
        callbacks=[tensorboard_callback],
    )

    finetuning_folder = str(OUTPUT_FOLDER / "finetuning")
    with open(f"{finetuning_folder}/metrics_history.json", "w") as f:
        json.dump(hist.history, f, indent=2)

    model.save(f"{finetuning_folder}/my_model.keras")

    model.export(f"{finetuning_folder}/exported_model", "tf_saved_model")
    converter = tf.lite.TFLiteConverter.from_saved_model(
        f"{finetuning_folder}/exported_model"
    )
    tflite_model = converter.convert()
    with open(f"{finetuning_folder}/model.tflite", "wb") as f:
        f.write(tflite_model)

    with open(f"{finetuning_folder}/labels.json", "w") as f:
        json.dump(label_info, f)

    with open(f"{finetuning_folder}/labels.txt", "w") as f:
        f.write("\n".join(label_info))
