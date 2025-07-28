from datetime import datetime

def log_sync(status, store_id, record_count=0, error=None):
    with open("sync_log.txt", "a") as f:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        line = f"[{now}] STATUS: {status} | Store: {store_id} | Records: {record_count}"
        if error:
            line += f" | ERROR: {error}"
        f.write(line + "\n")
