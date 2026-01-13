import pandas as pd
import sqlite3
from pathlib import Path

# Paths
csv_path = Path("data/hrrp_readmissions.csv")
db_path = Path("hospital.db")

# Load CSV
df = pd.read_csv(csv_path)

# Make column names SQL-friendly
df.columns = (
    df.columns.str.strip()
              .str.lower()
              .str.replace(" ", "_")
              .str.replace("/", "_")
              .str.replace("-", "_")
)

# Create SQLite DB
conn = sqlite3.connect(db_path)
df.to_sql("hrrp_readmissions", conn, if_exists="replace", index=False)
conn.close()

print("✅ Created hospital.db")
print("📊 Table: hrrp_readmissions")
print("🧱 Columns:")
print(df.columns.tolist())