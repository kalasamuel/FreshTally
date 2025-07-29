from reader_dispatcher import read_sales
from uploader import send_sales_to_firebase
from config_manager import load_config, get_store_id
from logger import log_sync

try:
    config = load_config()
    sales = read_sales(config)
    store_id = get_store_id()
    
    send_sales_to_firebase(sales, store_id)
    
    log_sync("success", store_id, record_count=len(sales))


except Exception as e:
    store_id = get_store_id()
    log_sync("failure", store_id, error=str(e))
