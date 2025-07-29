import firebase_admin
from firebase_admin import credentials, firestore
import os
import sys
import datetime

def get_resource_path(relative_path):
    """Get absolute path to resource, works for dev and PyInstaller .exe"""
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

# Load Firebase service account key
cred_path = get_resource_path("serviceAccountKey.json")
if not firebase_admin._apps:
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)

db = firestore.client()

def send_sales_to_firebase(sales_data, store_id):
    """
    Uploads sales data to /supermarkets/{store_id}/pos_transactions in Firestore.
    Internally we use 'store_id', but treat it as 'supermarket_id' in Firestore.
    """
    supermarket_id = store_id  # alias for clarity

    pos_collection = (
        db.collection("supermarkets")
        .document(supermarket_id)
        .collection("pos_transactions")
    )

    for sale in sales_data:
        sale_doc = sale.copy()
        sale_doc["supermarket_id"] = supermarket_id  # renamed for Firestore
        sale_doc["uploaded_at"] = datetime.datetime.now().isoformat()
        pos_collection.add(sale_doc)

    print(f"✅ Uploaded {len(sales_data)} sales to /supermarkets/{supermarket_id}/pos_transactions.")
