import pandas as pd
from pathlib import Path

data_folder = Path("data/raw")

csv_files = data_folder.glob("*.csv")

inventory = []

for file in csv_files:
    df = pd.read_csv(file)

    inventory.append(
        {
            "table_name" : file.stem,
            "rows" : len(df),
            "columns" : len(df.columns),
            "column_names" : ", ".join(df.columns)
        }
    )

inventory_df = pd.DataFrame(inventory)

print(inventory_df)