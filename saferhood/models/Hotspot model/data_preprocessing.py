import os
import pandas as pd

def preprocess_data(file_path):
    """
    Perform data preprocessing.

    Args:
        file_path (str): Path to the CSV file.

    Returns:
        pd.DataFrame: Preprocessed DataFrame.
    """
    # Load data
    data = pd.read_csv(file_path)

    # Convert FIR_Date to datetime
    data['FIR_Date'] = pd.to_datetime(data['FIR_Date'])

    return data

# List of file paths
file_paths = [
    "CASES OF HURT_data.csv",
    "CHEATING_data.csv",
    "CrPC_data.csv",
    "CYBER CRIME_data.csv",
    "KARNATAKA POLICE ACT 1963_data.csv",
    "Karnataka State Local Act_data.csv",
    "MISSING PERSON_data.csv",
    "NARCOTIC DRUGS & PSHYCOTROPIC SUBSTANCES_data.csv",
    "PUBLIC SAFETY_data.csv",
    "RIOTS_data.csv",
    "selected_data.csv",
    "THEFT_data.csv",
    "BURGLARY - NIGHT_data.csv"
]

# Perform data preprocessing for each file
for file_path in file_paths:
    print(f"Processing file: {file_path}")
    preprocessed_data = preprocess_data(file_path)

    # Save preprocessed data to a new CSV file
    preprocessed_save_path = f"preprocessed/{os.path.splitext(os.path.basename(file_path))[0]}.csv"
    preprocessed_data.to_csv(preprocessed_save_path, index=False)
