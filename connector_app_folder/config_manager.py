import json
import os

CONFIG_FILE = "config.json"

def save_config(data: dict):
    with open(CONFIG_FILE, "w") as f:
        json.dump(data, f, indent=4)

def load_config():
    if not os.path.exists(CONFIG_FILE):
        raise FileNotFoundError("config.json not found")

    with open(CONFIG_FILE, "r") as f:
        config = json.load(f)

    # Raise an error to trigger the GUI if config is empty or missing important values
    if not config or not config.get("store_id") or not config.get("source_type"):
        raise ValueError("config.json is missing required fields like 'store_id' or 'source_type'")

    return config

def get_store_id():
    try:
        config = load_config()
        return config.get("store_id")
    except Exception:
        return None

def set_store_id(store_id: str):
    config = load_config()
    config["store_id"] = store_id
    save_config(config)
