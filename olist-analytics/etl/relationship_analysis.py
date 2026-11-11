import pandas as pd
from pathlib import Path

DATA_FOLDER = Path("data/raw")

customers = pd.read_csv(DATA_FOLDER / "olist_customers_dataset.csv")
orders = pd.read_csv(DATA_FOLDER / "olist_orders_dataset.csv")
items = pd.read_csv(DATA_FOLDER / "olist_order_items_dataset.csv")

print("\nCUSTOMER → ORDERS")

orders_per_customer = (
    orders.groupby("customer_id")
    .size()
)

print("Max Orders By One Customer ID:",
      orders_per_customer.max())

print("Average Orders Per Customer ID:",
      round(orders_per_customer.mean(), 2))

print("\nORDER → ITEMS")

items_per_order = (
    items.groupby("order_id")
    .size()
)

print("Max Items In One Order:",
      items_per_order.max())

print("Average Items Per Order:",
      round(items_per_order.mean(), 2))