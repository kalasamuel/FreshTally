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
    Each sale is stored as a document with store ID and upload timestamp.
    """
    pos_collection = db.collection("supermarkets").document(store_id).collection("pos_transactions")

    for sale in sales_data:
        sale_doc = sale.copy()
        sale_doc["store_id"] = store_id
        sale_doc["uploaded_at"] = datetime.datetime.now().isoformat()
        pos_collection.add(sale_doc)

    print(f"✅ Uploaded {len(sales_data)} sales to /supermarkets/{store_id}/pos_transactions.")