import pickle
from pathlib import Path

import keras
import numpy as np
import tensorflow as tf
from cleanlab.internal.multilabel_utils import onehot2int
from cleanlab.multilabel_classification.filter import (
    find_label_issues,
    find_multilabel_issues_per_class,
)

OUTPUT_FOLDER = Path(__file__).resolve().parent.parent.parent / "output"


def analyze_dataset_with_model():
    finetuning_folder = str(OUTPUT_FOLDER / "finetuning")
    model = keras.saving.load_model(f"{finetuning_folder}/my_model.keras")
    # Serialize both the pipeline and binarizer to disk.
    with open(str(OUTPUT_FOLDER / "datasets" / "multi_label_binarizer.pkl"), "rb") as f:
        mlb = pickle.load(f)
    label_info = list(mlb.classes_)

    ds_train = tf.data.Dataset.load(str(OUTPUT_FOLDER / "datasets" / "ds_train"))
    dataset_batches = ds_train.batch(10)

    labels_l = []
    labels_names = []
    pred_label_names = []
    image_l = []
    image_path_l = []
    pred_probs_l = None
    i = 0

    for step, (image, labels, path) in enumerate(dataset_batches):
        i += 1
        # if i < 100:
        #     continue
        # if i > 100:
        #     break
        if len(image_path_l) > 7000:
            break
        labels_l.extend(onehot2int(labels))

        labels_names.extend(mlb.inverse_transform(labels.numpy()))

        image_l.extend(image)
        image_path_l.extend(path)
        y_pred = model.predict([image], verbose=0)
        pred_labels_l = onehot2int((y_pred > 0.5).astype(int))
        pred_label_names.extend(
            [
                [label_info[label] for label in pred_labels]
                for pred_labels in pred_labels_l
            ]
        )
        if pred_probs_l is None:
            pred_probs_l = y_pred
        else:
            pred_probs_l = np.concatenate((pred_probs_l, y_pred), axis=0)

    issues = find_label_issues(
        labels=labels_l,
        pred_probs=pred_probs_l,
        return_indices_ranked_by="self_confidence",
    )

    for i in issues:
        print(f"{pred_label_names[i]} {labels_names[i]} {image_path_l[i]}")

    issues = find_multilabel_issues_per_class(
        labels=labels_l,
        pred_probs=pred_probs_l,
        return_indices_ranked_by="self_confidence",
    )

    for ind, issues_per_c in enumerate(issues[0]):
        if len(issues_per_c) > 0:
            print(label_info[ind])
            for i in issues_per_c:
                print(f"{pred_label_names[i]} {labels_names[i]} {image_path_l[i]}")
            print()
