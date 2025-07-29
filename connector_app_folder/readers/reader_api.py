import requests

def read_sales_from_api(api_url, field_map, token=None):
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    response = requests.get(api_url, headers=headers)

    if response.status_code == 200:
        data = response.json()
        sales = []

        for item in data:
            sales.append({
                "name": item.get(field_map["name"], ""),
                "qty": int(item.get(field_map["qty"], 0)),
                "price": float(item.get(field_map["price"], 0)),
                "timestamp": item.get(field_map["timestamp"], "")
            })

        return sales
    else:
        raise Exception(f"API Error {response.status_code}: {response.text}")
