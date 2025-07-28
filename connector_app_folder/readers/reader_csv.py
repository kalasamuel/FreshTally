import csv

def read_sales_from_csv(path, field_map):
    sales = []
    with open(path, newline='', encoding="utf-8") as file:
        reader = csv.DictReader(file)
        for row in reader:
            sales.append({
                "name": row.get(field_map["name"], ""),
                "qty": int(row.get(field_map["qty"], 0)),
                "price": float(row.get(field_map["price"], 0)),
                "timestamp": row.get(field_map["timestamp"], "")
            })
    return sales
