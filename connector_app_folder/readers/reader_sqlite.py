import sqlite3

def read_sales_from_sqlite(db_path, field_map):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Build query using mapped fields
    query = f"""
        SELECT {field_map["productName"]}, {field_map["quantity"]}, {field_map["unitPrice"]}, {field_map["transaction_timestamp"]}, {field_map["productId"]}, {field_map["sku"]}, {field_map["transactionId"]}
        FROM sales
    """
    cursor.execute(query)
    rows = cursor.fetchall()
    conn.close()

    return [
        {
            "productName": row[0],
            "quantity": int(row[1]),
            "unitPrice": float(row[2]),
            "timestamp": row[3],
            "productId": row[4],
            "sku": row[5],
            "transactionId" : row[6]

        }
        for row in rows
    ]
