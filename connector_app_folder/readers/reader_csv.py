import csv

def read_sales_from_csv(path, field_map):
    sales = []
    with open(path, newline='', encoding="utf-8") as file:
        reader = csv.DictReader(file)
        for row in reader:
                sales.append({
                "productName": row.get(field_map["productName"], ""),
                "quantity": int(row.get(field_map["quantity"], 0)),
                "unitPrice": float(row.get(field_map["unitPrice"], 0)),
                "timestamp": row.get(field_map["transaction_timestamp"], ""),
                "sku": row.get(field_map["sku"], ""),
                "productId": row.get(field_map["productId"], ""),
                "transactionId": row.get(field_map["transactionId"], ""),
            })

    return sales
