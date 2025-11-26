"""
Simple Python-style pseudocode for product usage ingestion.

Idea:
- Called by ADF (Azure Function / Databricks).
- For each date, call the product usage API.
- Write raw JSON files to Blob, partitioned by date.
"""

import datetime as dt
import json
import requests
from azure.storage.blob import BlobServiceClient  # example library


API_BASE_URL = "https://api.product.com/v1/company-usage"
API_KEY = "<YOUR_API_KEY>"
BLOB_CONN_STR = "<BLOB_CONNECTION_STRING>"
BLOB_CONTAINER = "raw-product-usage"


def call_product_api(date_str: str, page: int = 1) -> dict:
    """Call the product usage API for a single date + page."""
    headers = {"Authorization": f"Bearer {API_KEY}"}
    params = {"date": date_str, "page": page, "page_size": 1000}
    resp = requests.get(API_BASE_URL, headers=headers, params=params, timeout=30)
    resp.raise_for_status()
    return resp.json()


def upload_to_blob(content: str, blob_path: str) -> None:
    """Upload a JSON string to Blob at the given path."""
    service = BlobServiceClient.from_connection_string(BLOB_CONN_STR)
    blob = service.get_blob_client(container=BLOB_CONTAINER, blob=blob_path)
    blob.upload_blob(content, overwrite=True)


def ingest_product_usage(start_date: dt.date, end_date: dt.date) -> None:
    """Loop over dates, call API, write JSON to Blob."""
    current = start_date
    while current <= end_date:
        date_str = current.strftime("%Y-%m-%d")
        page = 1
        while True:
            data = call_product_api(date_str, page)
            raw_str = json.dumps(data)
            blob_path = f"date={date_str}/product_usage_page={page}.json"
            upload_to_blob(raw_str, blob_path)

            if not data.get("has_more", False):
                break
            page += 1

        current += dt.timedelta(days=1)


if __name__ == "__main__":
    # Example: ingest yesterday only
    today = dt.date.today()
    yesterday = today - dt.timedelta(days=1)
    ingest_product_usage(yesterday, yesterday)