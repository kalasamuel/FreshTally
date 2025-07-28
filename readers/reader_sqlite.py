import sqlite3

def read_sales_from_sqlite(db_path, field_map):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Build query using mapped fields
    query = f"""
        SELECT {field_map["name"]}, {field_map["qty"]}, {field_map["price"]}, {field_map["timestamp"]}
        FROM sales
    """
    cursor.execute(query)
    rows = cursor.fetchall()
    conn.close()

    return [
        {
            "name": row[0],
            "qty": int(row[1]),
            "price": float(row[2]),
            "timestamp": row[3]
        }
        for row in rows
    ]
