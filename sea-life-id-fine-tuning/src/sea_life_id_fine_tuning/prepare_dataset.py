import itertools
import json
import pickle
from pathlib import Path
from typing import Counter, List, Optional

import numpy as np
import tensorflow as tf  # For tf.data
from iterstrat.ml_stratifiers import MultilabelStratifiedShuffleSplit
from keras import layers
from sklearn.preprocessing import MultiLabelBinarizer

# IMG_SIZE is determined by EfficientNet model choice
IMG_SIZE = 224
BATCH_SIZE = 64
TRAIN_MODEL = False

OUTPUT_FOLDER = Path(__file__).resolve().parent.parent.parent / "output"


def load_image(path: str) -> tf.Tensor:
    """Loads a jpeg/png image and returns an image tensor."""
    image_raw = tf.io.read_file(path)
    image_tensor = tf.cond(
        tf.io.is_jpeg(image_raw),
        lambda: tf.io.decode_jpeg(image_raw, channels=3),
        lambda: tf.io.decode_png(image_raw, channels=3),
    )
    return image_tensor


def build_dataset(
    mlb,
    csv_p: str,
    image_dir: Path,
    with_image: bool,
    filenames_filter: Optional[List[str]],
    keep_only_small_subset: bool = False,
):
    all_image_paths = []
    all_image_str_labels = []
    with csv_p.open("r") as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            lsplitted = line.strip().split(",")
            filename = lsplitted[0].replace("gs://sea-life-id-images/", "")
            labels = lsplitted[1:]

            if filenames_filter is not None and filename not in filenames_filter:
                continue

            all_image_paths.append(str((image_dir / filename).resolve()))
            all_image_str_labels.append(labels)

            if keep_only_small_subset and i > 1500:
                break

    all_image_size = len(all_image_paths)

    if all_image_size == 0:
        raise ValueError("Image size is zero")

    if not with_image:
        labels = mlb.fit_transform(all_image_str_labels)
    else:
        labels = mlb.transform(all_image_str_labels)

    path_ds = tf.data.Dataset.from_tensor_slices(all_image_paths)
    if with_image:
        image_ds = path_ds.map(load_image, num_parallel_calls=tf.data.AUTOTUNE).map(
            lambda image: tf.image.resize(image, (IMG_SIZE, IMG_SIZE))
        )

    label_ds = tf.data.Dataset.from_tensor_slices(labels)

    if with_image:
        image_label_ds = tf.data.Dataset.zip((image_ds, label_ds, path_ds))
    else:
        image_label_ds = tf.data.Dataset.zip((label_ds, path_ds))
    return image_label_ds


def format_label(mlb, label_encoded, NUM_CLASSES):
    label_encoded = np.array(tf.reshape(label_encoded, [1, NUM_CLASSES]))
    labels = mlb.inverse_transform(label_encoded)
    labels_str = " ".join(labels[0])
    return labels_str


img_augmentation_layers = [
    layers.RandomRotation(factor=0.15),
    layers.RandomTranslation(height_factor=0.1, width_factor=0.1),
    layers.RandomFlip(),
    layers.RandomContrast(factor=0.1),
]


def img_augmentation(images):

    for layer in img_augmentation_layers:
        images = layer(images)
    return images


def prepare_dataset(data_folder: str):
    csv_p = Path(f"{data_folder}/generated_tags.csv")
    image_dir = Path(f"{data_folder}/")
    mlb = MultiLabelBinarizer()
    ds = build_dataset(mlb, csv_p, image_dir, with_image=False, filenames_filter=None)
    ds_l = list(ds)
    label_info = list(mlb.classes_)

    Y = [e[0] for e in ds_l]
    mskf = MultilabelStratifiedShuffleSplit(n_splits=1, test_size=0.2, random_state=0)
    split = mskf.split(range(len(ds)), Y)
    ds_train_index, ds_test_index = next(split)

    # ds_train_index, ds_remaining_index = next(split)
    # Y = [e[0] for i, e in enumerate(ds.as_numpy_iterator()) if i in ds_remaining_index]
    # mskf = MultilabelStratifiedShuffleSplit(n_splits=1, test_size=0.5, random_state=0)
    # split = mskf.split(ds_remaining_index, Y)
    # ds_test_index_tmp, ds_validation_index_tmp = next(split)
    # ds_test_index = [index for i, index in enumerate(ds_remaining_index) if i in ds_test_index_tmp]
    # ds_validation_index = [index for i, index in enumerate(ds_remaining_index) if i in ds_validation_index_tmp]

    ds_filenames_train = [
        ds_l[i][1].numpy().decode().replace(f"{data_folder}/", "")
        for i in ds_train_index
    ]
    ds_filenames_test = [
        ds_l[i][1].numpy().decode().replace(f"{data_folder}/", "")
        for i in ds_test_index
    ]
    # ds_filenames_validation = [ds_l[i][1].numpy().decode().replace("/data/", "") for i in ds_validation_index]
    # ds_validation = [ds_remaining[i] for i in ds_validation_index]

    ds_train = build_dataset(
        mlb, csv_p, image_dir, with_image=True, filenames_filter=ds_filenames_train
    )
    ds_test = build_dataset(
        mlb, csv_p, image_dir, with_image=True, filenames_filter=ds_filenames_test
    )
    # ds_validation = build_dataset(mlb, csv_p, image_dir,with_image=True, filenames_filter=ds_filenames_validation)

    # get stats
    labels_in_train = [
        list(
            mlb.inverse_transform(
                tf.reshape(tf.cast(e[1], tf.bool), [1, len(label_info)])
            )[0]
        )
        for e in ds_train
    ]
    counter_labels_in_train = Counter(
        list(itertools.chain.from_iterable(labels_in_train))
    )

    labels_in_test = [
        list(
            mlb.inverse_transform(
                tf.reshape(tf.cast(e[1], tf.bool), [1, len(label_info)])
            )[0]
        )
        for e in ds_test
    ]
    counter_labels_in_test = Counter(
        list(itertools.chain.from_iterable(labels_in_test))
    )

    with open(str(OUTPUT_FOLDER / "datasets" / "labels_dataset_split.json"), "w") as f:
        json.dump(
            {
                "train": dict(sorted(counter_labels_in_train.items())),
                "test": dict(sorted(counter_labels_in_test.items())),
            },
            f,
            indent=4,
        )

    def input_preprocess_train(image, encoded_label, path):
        image = img_augmentation(image)
        return image, encoded_label, path

    def input_preprocess_test(image, encoded_label, path):
        return image, encoded_label, path

    ds_train = ds_train.map(input_preprocess_train, num_parallel_calls=tf.data.AUTOTUNE)
    ds_train_batch = ds_train.batch(batch_size=BATCH_SIZE, drop_remainder=True)
    ds_train_batch = ds_train_batch.prefetch(tf.data.AUTOTUNE)

    ds_test = ds_test.map(input_preprocess_test, num_parallel_calls=tf.data.AUTOTUNE)
    ds_test_batch = ds_test.batch(batch_size=BATCH_SIZE, drop_remainder=True)

    with open(str(OUTPUT_FOLDER / "datasets" / "multi_label_binarizer.pkl"), "wb") as f:
        pickle.dump(mlb, f)

    ds_train.save(str(OUTPUT_FOLDER / "datasets" / "ds_train"))
    ds_train_batch.save(str(OUTPUT_FOLDER / "datasets" / "ds_train_batch"))
    ds_test.save(str(OUTPUT_FOLDER / "datasets" / "ds_test"))
    ds_test_batch.save(str(OUTPUT_FOLDER / "datasets" / "ds_test_batch"))
