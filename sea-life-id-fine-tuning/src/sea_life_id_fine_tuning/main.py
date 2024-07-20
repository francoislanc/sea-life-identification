import logging

import fire
from dotenv import load_dotenv

from sea_life_id_fine_tuning.analyze_dataset import analyze_dataset_with_model
from sea_life_id_fine_tuning.finetune_model import run_finetuning
from sea_life_id_fine_tuning.prepare_dataset import prepare_dataset
from sea_life_id_fine_tuning.run_inference import run_inference
from sea_life_id_fine_tuning.visualize_dataset import visualize_dataset

logging.basicConfig(
    filename="logs.log",
    level=logging.DEBUG,
    filemode="w",
    format="%(asctime)s -> %(levelname)s: %(message)s",
)


load_dotenv()


def run() -> None:
    fire.Fire(
        {
            "prepare_dataset": prepare_dataset,
            "visualize_dataset": visualize_dataset,
            "run_finetuning": run_finetuning,
            "analyze_dataset": analyze_dataset_with_model,
            "run_inference": run_inference,
        }
    )


if __name__ == "__main__":
    run()
