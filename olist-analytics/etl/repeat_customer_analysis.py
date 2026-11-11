import pandas as pd
from pathlib import Path

DATA_FOLDER = Path("data/raw")

customers = pd.read_csv(
    DATA_FOLDER / "olist_customers_dataset.csv"
)

repeat_customers = (
    customers["customer_unique_id"]
    .value_counts()
)

print("\nTotal Unique Customers:")
print(customers["customer_unique_id"].nunique())

print("\nCustomers With More Than 1 Order:")
print((repeat_customers > 1).sum())

print("\nTop 10 Repeat Customers:")
print(repeat_customers.head(10))