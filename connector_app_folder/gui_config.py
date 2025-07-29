import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import json
import os
import csv
import sqlite3
import requests

CONFIG_FILE = "config.json"

def launch_config_gui():
    def choose_file(entry):
        path = filedialog.askopenfilename()
        entry.delete(0, tk.END)
        entry.insert(0, path)

    def is_valid_store_id(store_id):
        return store_id.isalnum() and len(store_id) > 0

    def save_config():
        source_type = source_var.get().upper()
        store_id = store_id_entry.get().strip()

        if not source_type or not store_id:
            messagebox.showerror("Missing Info", "Please select source type and enter Store ID.")
            return
        
        if is_valid_store_id(store_id):
            messagebox.showerror("Invalid Store ID", "Store ID must be alphanumeric and non-empty.")
            return

        config = {
            "source_type": source_type,
            "store_id": store_id,
            "field_mapping": {field: var.get() for field, var in field_vars.items()}
        }

        # Add source-specific data
        if source_type == "CSV":
            config["csv_path"] = csv_path_entry.get()
        elif source_type == "SQLITE":
            config["sqlite_path"] = sqlite_path_entry.get()
        elif source_type == "MYSQL":
            config["mysql"] = {
                "host": host_entry.get(),
                "user": user_entry.get(),
                "password": password_entry.get(),
                "database": database_entry.get()
            }
        elif source_type == "API":
            config["api_url"] = api_url_entry.get()
            config["api_token"] = api_token_entry.get()

        # Check field mappings
        missing = [label for key, label in field_labels.items() if not field_vars[key].get()]
        if missing:
            messagebox.showwarning("Missing Fields", f"Map all required fields:\n\n{chr(10).join(missing)}")
            return

        with open(CONFIG_FILE, "w") as f:
            json.dump(config, f, indent=4)

        messagebox.showinfo("Success", "Configuration saved successfully.")
        root.destroy()

    def show_fields(event=None):
        for frame in all_frames:
            frame.pack_forget()
        selected = source_var.get()
        if selected == "CSV":
            csv_frame.pack(fill="x")
        elif selected == "SQLite":
            sqlite_frame.pack(fill="x")
        elif selected == "MySQL":
            mysql_frame.pack(fill="x")
        elif selected == "API":
            api_frame.pack(fill="x")

    def detect_columns():
        try:
            source = source_var.get()
            columns = []

            if source == "CSV":
                path = csv_path_entry.get()
                with open(path, newline='', encoding='utf-8') as f:
                    reader = csv.DictReader(f)
                    columns = reader.fieldnames or []

            elif source == "SQLite":
                path = sqlite_path_entry.get()
                conn = sqlite3.connect(path)
                cursor = conn.cursor()
                cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
                tables = cursor.fetchall()
                if tables:
                    cursor.execute(f"PRAGMA table_info({tables[0][0]});")
                    columns = [row[1] for row in cursor.fetchall()]
                conn.close()

            elif source == "MySQL":
                import mysql.connector
                conn = mysql.connector.connect(
                    host=host_entry.get(),
                    user=user_entry.get(),
                    password=password_entry.get(),
                    database=database_entry.get()
                )
                cursor = conn.cursor()
                cursor.execute("SHOW TABLES;")
                tables = cursor.fetchall()
                if tables:
                    cursor.execute(f"DESCRIBE {tables[0][0]};")
                    columns = [row[0] for row in cursor.fetchall()]
                conn.close()

            elif source == "API":
                url = api_url_entry.get()
                token = api_token_entry.get()
                headers = {"Authorization": f"Bearer {token}"} if token else {}
                response = requests.get(url, headers=headers)
                if response.status_code == 200:
                    data = response.json()
                    if isinstance(data, list) and len(data) > 0:
                        columns = list(data[0].keys())
                else:
                    raise Exception(f"API returned status code {response.status_code}")

            if not columns:
                raise Exception("No columns found")

            for var in field_vars.values():
                var.set("")
            for dropdown in field_dropdowns.values():
                dropdown.config(values=columns)

        except Exception as e:
            messagebox.showerror("Detection Failed", str(e))

    root = tk.Tk()
    root.title("Connector Configuration")

    # Source type and Store ID
    tk.Label(root, text="Store ID:").pack()
    store_id_entry = tk.Entry(root)
    store_id_entry.pack()

    tk.Label(root, text="POS Source Type:").pack()
    source_var = tk.StringVar()
    source_dropdown = ttk.Combobox(root, textvariable=source_var, values=["CSV", "SQLite", "MySQL", "API"])
    source_dropdown.bind("<<ComboboxSelected>>", show_fields)
    source_dropdown.pack()

    # Source-specific frames
    csv_frame = tk.Frame(root)
    tk.Label(csv_frame, text="CSV File Path:").pack()
    csv_path_entry = tk.Entry(csv_frame)
    csv_path_entry.pack()
    ttk.Button(csv_frame, text="Browse", command=lambda: choose_file(csv_path_entry)).pack()

    sqlite_frame = tk.Frame(root)
    tk.Label(sqlite_frame, text="SQLite DB Path:").pack()
    sqlite_path_entry = tk.Entry(sqlite_frame)
    sqlite_path_entry.pack()
    ttk.Button(sqlite_frame, text="Browse", command=lambda: choose_file(sqlite_path_entry)).pack()

    mysql_frame = tk.Frame(root)
    tk.Label(mysql_frame, text="Host:").pack()
    host_entry = tk.Entry(mysql_frame)
    host_entry.pack()
    tk.Label(mysql_frame, text="User:").pack()
    user_entry = tk.Entry(mysql_frame)
    user_entry.pack()
    tk.Label(mysql_frame, text="Password:").pack()
    password_entry = tk.Entry(mysql_frame, show="*")
    password_entry.pack()
    tk.Label(mysql_frame, text="Database:").pack()
    database_entry = tk.Entry(mysql_frame)
    database_entry.pack()

    api_frame = tk.Frame(root)
    tk.Label(api_frame, text="API URL:").pack()
    api_url_entry = tk.Entry(api_frame)
    api_url_entry.pack()
    tk.Label(api_frame, text="API Token (optional):").pack()
    api_token_entry = tk.Entry(api_frame)
    api_token_entry.pack()

    all_frames = [csv_frame, sqlite_frame, mysql_frame, api_frame]

    # Field Mapping
    tk.Label(root, text="\nField Mapping:").pack()
    mapping_frame = tk.Frame(root)
    mapping_frame.pack(padx=10, pady=5)

    field_labels = {
        "productId": "Product ID",
        "productName": "Product Name",
        "quantity": "Quantity",
        "unitPrice": " Unit Price",
        "timestamp": "Timestamp",
        "sku": "SKU",
        "transactionId" : "Transaction ID"

    }

    # Create field variables and dropdowns
    field_vars = {}
    field_dropdowns = {}
    for field, label in field_labels.items():
        row = tk.Frame(mapping_frame)
        row.pack(fill="x", pady=2)
        tk.Label(row, text=label, width=15, anchor="w").pack(side="left")
        var = tk.StringVar()
        dropdown = ttk.Combobox(row, textvariable=var, values=[], state="normal")
        dropdown.pack(side="left", fill="x", expand=True)
        field_vars[field] = var
        field_dropdowns[field] = dropdown

    tk.Button(root, text="Detect Columns", command=detect_columns).pack(pady=5)
    tk.Button(root, text="Save Configuration", command=save_config).pack(pady=10)

    root.mainloop()
