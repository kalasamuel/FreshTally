import requests

def read_sales_from_api(api_url, field_map, token=None):
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    response = requests.get(api_url, headers=headers)

    if response.status_code == 200:
        data = response.json()
        sales = []  

        for item in data:
            sales.append({
                "productName": item.get(field_map["productName"], ""),
                "quantity": int(item.get(field_map["quantity"], 0)),
                "unitPrice": float(item.get(field_map["unitPrice"], 0)),
                "transaction_timestamp": item.get(field_map["transaction_timestamp"], ""),
                "sku": item.get(field_map["sku"], ""),
                "productId": item.get(field_map["productId"], ""),
                "transactionId": item.get(field_map["transactionId"], ""),
            })

        return sales
    else:
        raise Exception(f"API Error {response.status_code}: {response.text}")
