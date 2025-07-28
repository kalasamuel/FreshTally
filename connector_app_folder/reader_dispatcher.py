from readers.reader_csv import read_sales_from_csv
from readers.reader_sqlite import read_sales_from_sqlite
from readers.reader_mysql import read_sales_from_mysql
from readers.reader_api import read_sales_from_api

def read_sales(config):
    source_type = config.get("source_type", "").upper()
    field_map = config.get("field_mapping", {})

    if source_type == "CSV":
        return read_sales_from_csv(config["csv_path"], field_map)
    elif source_type == "SQLITE":
        return read_sales_from_sqlite(config["sqlite_path"], field_map)
    elif source_type == "MYSQL":
        return read_sales_from_mysql(config["mysql"], field_map)
    elif source_type == "API":
        return read_sales_from_api(config["api_url"], field_map, config.get("api_token"))
    else:
        raise ValueError(f"Unsupported source type:'{source_type}'")