import pandas as pd

# Read the filtered CSV file into a DataFrame
data = pd.read_csv("filtered_cheating_data.csv")

# Convert DataFrame to JSON
data.to_json("filtered_burglary_data.json", orient="records")

print("CSV file converted to JSON successfully.")