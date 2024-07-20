from pathlib import Path

import datasets
import numpy as np
import tensorflow as tf
from PIL import Image
from renumics import spotlight
from transformers import AutoImageProcessor, AutoModel

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


def extract_embeddings(model, feature_extractor):
    device = model.device

    def pp(batch):
        inputs = feature_extractor(
            images=[x.convert("RGB") for x in batch["image"]], return_tensors="pt"
        ).to(device)
        embeddings = model(**inputs).last_hidden_state[:, 0].cpu()
        return {"embedding": embeddings}

    return pp


def create_dataset_with_embeddings(
    data_folder: str, dataset_p: Path, keep_only_small_subset: bool = False
):
    csv_p = Path(f"{data_folder}/generated_tags.csv")
    image_dir = Path(f"{data_folder}/")
    all_paths = []
    all_images = []
    all_image_str_labels = []
    all_image_labels = []
    with csv_p.open("r") as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            lsplitted = line.strip().split(",")
            filename = lsplitted[0].replace("gs://sea-life-id-images/", "")
            labels = lsplitted[1:]
            labels.sort()
            im = Image.open(image_dir / filename)
            all_images.append(im)
            all_image_str_labels.append("-".join(labels))
            all_image_labels.append(labels)
            all_paths.append(filename)

            if keep_only_small_subset and i == 500:
                break

    ds = datasets.Dataset.from_dict(
        {
            "image": all_images,
            "labels": all_image_labels,
            "label_str": all_image_str_labels,
            "path": all_paths,
        }
    )

    modelname = "google/vit-base-patch16-224"
    feature_extractor = AutoImageProcessor.from_pretrained(modelname, device_map="auto")
    model = AutoModel.from_pretrained(
        modelname, output_hidden_states=True, device_map="auto"
    )
    extract_fn = extract_embeddings(model, feature_extractor)
    ds = ds.map(extract_fn, batched=True, batch_size=24)
    ds.save_to_disk(dataset_p)
    return ds


def visualize_dataset(
    data_folder: str, force_rebuild: bool = False, keep_only_small_subset: bool = False
):
    dataset_p = OUTPUT_FOLDER / "datasets" / "embeddings"
    if not force_rebuild and dataset_p.exists():
        ds = datasets.load_from_disk(dataset_p)
    else:
        ds = create_dataset_with_embeddings(
            data_folder, dataset_p, keep_only_small_subset
        )
    dtypes = {
        "image": spotlight.Image,
        "embedding": spotlight.Embedding,
        "labels": np.ndarray,
        "label_str": str,
    }
    spotlight.show(ds, dtype=dtypes, host="0.0.0.0", port=6006, no_ssl=True)
