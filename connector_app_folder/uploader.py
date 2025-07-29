import firebase_admin
from firebase_admin import credentials, firestore
import os
import sys
import datetime

def get_resource_path(relative_path):
    """Get absolute path to resource, works for dev and PyInstaller .exe"""
    try:
        base_path = sys._MEIPASS  # PyInstaller temp directory
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

# Load Firebase service account key
cred_path = get_resource_path("serviceAccountKey.json")
if not firebase_admin._apps:
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

db = firestore.client()

def send_sales_to_firebase(sales_data, store_id="default_store"):
    """
    Uploads sales data to Firebase Firestore under a store's batches collection.
    sales_data: List of dicts like:
      [
        {"product_id": "A123", "name": "Milk", "qty": 2, "price": 4500, "timestamp": "2024-07-07T13:00:00"},
        ...
      ]
    store_id: Firestore document ID for the store.
    """
    store_ref = db.collection("sales").document(store_id)
    batch_ref = store_ref.collection("batches").document(datetime.datetime.now().isoformat())
    batch_ref.set({"uploaded": True, "count": len(sales_data)})

    for sale in sales_data:
        batch_ref.collection("items").add(sale)

    print(f"✅ Uploaded {len(sales_data)} sales to Firestore.")


