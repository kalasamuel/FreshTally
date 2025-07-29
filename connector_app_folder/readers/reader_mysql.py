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
            "transaction_timestamp": row[3],
            "productId": row[4],
            "sku": row[5],
            "transactionId" : row[6]
        }
        for row in rows
    ]
