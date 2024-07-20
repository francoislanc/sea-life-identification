import pickle
from pathlib import Path

import keras
import tensorflow as tf

OUTPUT_FOLDER = Path(__file__).resolve().parent.parent.parent / "output"
IMG_SIZE = 224


def load_image(path: str) -> tf.Tensor:
    """Loads a jpeg/png image and returns an image tensor."""
    image_raw = tf.io.read_file(path)
    image_tensor = tf.cond(
        tf.io.is_jpeg(image_raw),
        lambda: tf.io.decode_jpeg(image_raw, channels=3),
        lambda: tf.io.decode_png(image_raw, channels=3),
    )
    return image_tensor


def run_keras_inference(image: str, threshold: float):
    finetuning_folder = str(OUTPUT_FOLDER / "finetuning")
    model = keras.saving.load_model(f"{finetuning_folder}/my_model.keras")

    with open(str(OUTPUT_FOLDER / "datasets" / "multi_label_binarizer.pkl"), "rb") as f:
        mlb = pickle.load(f)
    img = load_image(image)
    img_resized = tf.image.resize(img, (IMG_SIZE, IMG_SIZE))
    y_pred = model.predict(tf.expand_dims(img_resized, axis=0))

    labels = mlb.inverse_transform((y_pred > threshold).astype(int))
    return y_pred, labels


def run_tflite_inference(image: str, threshold: float):
    finetuning_folder = str(OUTPUT_FOLDER / "finetuning")
    interpreter = tf.lite.Interpreter(f"{finetuning_folder}/model.tflite")

    with open(str(OUTPUT_FOLDER / "datasets" / "multi_label_binarizer.pkl"), "rb") as f:
        mlb = pickle.load(f)
    img = load_image(image)
    img_resized = tf.image.resize(img, (IMG_SIZE, IMG_SIZE))

    model_signature = interpreter.get_signature_runner()
    y_pred = model_signature(keras_tensor=tf.expand_dims(img_resized, axis=0))
    labels = mlb.inverse_transform((y_pred["output_0"] > threshold).astype(int))
    return y_pred, labels


def run_inference(image: str, with_tflite: bool, threshold: float):
    if with_tflite:
        y_pred, labels = run_tflite_inference(image, threshold)
    else:
        y_pred, labels = run_keras_inference(image, threshold)
    print(f"{y_pred=}\n\n{labels=}")
