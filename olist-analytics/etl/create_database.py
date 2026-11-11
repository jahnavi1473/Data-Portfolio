
import os
# import psycopg2
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

# Load environment variables
load_dotenv()

DB_NAME = os.getenv("DB_NAME")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# Validate configuration
if not all([DB_NAME, DB_HOST, DB_PORT, DB_USER, DB_PASSWORD]):
    raise ValueError("Missing database configuration in .env file")

# Connect to the default PostgreSQL database
connection_url = URL.create(
    drivername="postgresql+psycopg2",
    username=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=int(DB_PORT),
    database="postgres"
)

engine = create_engine(
    connection_url,
    isolation_level="AUTOCOMMIT"
)

try:
    with engine.connect() as conn:

        result = conn.execute(
            text(
                "SELECT 1 FROM pg_database WHERE datname = :db_name"
            ),
            {"db_name": DB_NAME}
        )

        database_exists = result.scalar() is not None

        if database_exists:
            print(f"Database '{DB_NAME}' already exists.")

        else:
            # Database names cannot be passed as SQL bind parameters.
            # Quote the identifier safely.
            quoted_db_name = '"' + DB_NAME.replace('"', '""') + '"'

            conn.execute(
                text(f"CREATE DATABASE {quoted_db_name}")
            )

            print(f"Database '{DB_NAME}' created successfully!")

except Exception as e:
    print("Database creation failed!")
    print(e)

finally:
    engine.dispose()
