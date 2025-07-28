import tkinter as tk
import sys
import os
from tkinter import messagebox
from gui_config import launch_config_gui
from reader_dispatcher import read_sales
from uploader import send_sales_to_firebase
from config_manager import load_config, get_store_id
from logger import log_sync

if getattr(sys, 'frozen', False):
    os.chdir(sys._MEIPASS)

# import json
# config = load_config()
# print("DEBUG config content:", json.dumps(config, indent=2))


def main():
    # Load or prompt for configuration
    try:
        config = load_config()
    except Exception:
        launch_config_gui()
        config = load_config()

    # Use fallback if store_id is not set
    store_id = get_store_id() or config.get("store_id", "unknown")

    try:
        sales = read_sales(config)
        send_sales_to_firebase(sales, store_id)

        log_sync("SUCCESS", store_id, len(sales))

        # ✅ Show success popup
        root = tk.Tk()
        root.withdraw()
        messagebox.showinfo("Success", f"Uploaded {len(sales)} sales records for store: {store_id}")

    except Exception as e:
        log_sync("FAILED", store_id, error=str(e))
        root = tk.Tk()
        root.withdraw()
        messagebox.showerror("Upload Failed", f"An error occurred:\n{str(e)}")



if __name__ == "__main__":
    main()
    