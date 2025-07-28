import mysql.connector

def read_sales_from_mysql(mysql_config, field_map):
    conn = mysql.connector.connect(
        host=mysql_config["host"],
        user=mysql_config["user"],
        password=mysql_config["password"],
        database=mysql_config["database"]
    )
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
