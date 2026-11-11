import pandas as pd
from pathlib import Path

DATA_FOLDER = Path("data/raw")

# -------------------------------
# CUSTOMERS
# -------------------------------
customers = pd.read_csv(DATA_FOLDER / "olist_customers_dataset.csv")

print("\n" + "=" * 80)
print("CUSTOMERS")
print("=" * 80)

print(f"Total Rows: {len(customers):,}")

print(
    f"Unique customer_id: "
    f"{customers['customer_id'].nunique():,}"
)

print(
    f"Unique customer_unique_id: "
    f"{customers['customer_unique_id'].nunique():,}"
)

# -------------------------------
# ORDERS
# -------------------------------
orders = pd.read_csv(DATA_FOLDER / "olist_orders_dataset.csv")

print("\n" + "=" * 80)
print("ORDERS")
print("=" * 80)

print(f"Total Rows: {len(orders):,}")

print(
    f"Unique order_id: "
    f"{orders['order_id'].nunique():,}"
)

print(
    f"Unique customer_id in orders: "
    f"{orders['customer_id'].nunique():,}"
)

# -------------------------------
# PRODUCTS
# -------------------------------
products = pd.read_csv(DATA_FOLDER / "olist_products_dataset.csv")

print("\n" + "=" * 80)
print("PRODUCTS")
print("=" * 80)

print(f"Total Rows: {len(products):,}")

print(
    f"Unique product_id: "
    f"{products['product_id'].nunique():,}"
)

# -------------------------------
# SELLERS
# -------------------------------
sellers = pd.read_csv(DATA_FOLDER / "olist_sellers_dataset.csv")

print("\n" + "=" * 80)
print("SELLERS")
print("=" * 80)

print(f"Total Rows: {len(sellers):,}")

print(
    f"Unique seller_id: "
    f"{sellers['seller_id'].nunique():,}"
)

# -------------------------------
# REVIEWS
# -------------------------------
reviews = pd.read_csv(DATA_FOLDER / "olist_order_reviews_dataset.csv")

print("\n" + "=" * 80)
print("REVIEWS")
print("=" * 80)

print(f"Total Rows: {len(reviews):,}")

print(
    f"Unique review_id: "
    f"{reviews['review_id'].nunique():,}"
)

print(
    f"Unique order_id in reviews: "
    f"{reviews['order_id'].nunique():,}"
)