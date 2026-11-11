import pandas as pd
from pathlib import Path

DATA_FOLDER = Path("data/raw")

for file in DATA_FOLDER.glob("*.csv"):

    print("\n" + "=" * 80)
    print(f"TABLE: {file.stem}")
    print("=" * 80)

    df = pd.read_csv(file)

    print("\nShape:")
    print(df.shape)

    print("\nColumns:")
    print(df.columns.tolist())

    print("\nData Types:")
    print(df.dtypes)

    print("\nNull Values:")
    print(df.isnull().sum())

    print("\n" + "-" * 80)