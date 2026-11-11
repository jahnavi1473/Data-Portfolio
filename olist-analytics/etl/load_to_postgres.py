
import os
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from dotenv import load_dotenv

# -------------------------
# LOAD ENVIRONMENT VARIABLES
# -------------------------

load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

if not all([DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD]):
    raise ValueError("Missing database configuration in .env file")

# -------------------------
# DATABASE CONNECTION
# -------------------------

connection_url = URL.create(
    drivername="postgresql+psycopg2",
    username=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=int(DB_PORT),
    database=DB_NAME
)

engine = create_engine(connection_url)

# -------------------------
# DATA FOLDER
# -------------------------

DATA_FOLDER = Path("data/raw")

if not DATA_FOLDER.exists():
    raise FileNotFoundError(f"Data folder not found: {DATA_FOLDER}")

# -------------------------
# TABLE MAPPINGS
# -------------------------

tables = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_translation": "product_category_name_translation.csv"
}

# -------------------------
# LOAD TABLES
# -------------------------

try:
    with engine.connect() as conn:
        print("PostgreSQL connection successful!")

    for table_name, file_name in tables.items():

        file_path = DATA_FOLDER / file_name

        if not file_path.exists():
            raise FileNotFoundError(f"CSV file not found: {file_path}")

        print(f"\nLoading {table_name}...")

        df = pd.read_csv(file_path)

        df.to_sql(
            table_name,
            engine,
            if_exists="replace",
            index=False
        )

        print(f"Loaded {len(df):,} rows into {table_name}")

    print("\nAll tables loaded successfully!")

except Exception as e:
    print("\nData loading failed!")
    print(e)
    raise

finally:
    engine.dispose()
