import os
import torch
import pandas as pd
from data_preprocessing import preprocess_data
from model import ConvLSTMModel

def train_model_and_predict(file_path):
    """
    Train the ConvLSTM model and generate predictions for a single file.

    Args:
        file_path (str): Path to the CSV file.

    Returns:
        None
    """
    # Load and preprocess data
    preprocessed_data = preprocess_data(file_path)

    # Convert preprocessed data to PyTorch tensor
    input_tensor = torch.Tensor(preprocessed_data.values) 

    # Define target tensor (assuming target is the next coordinate in the sequence)
    target_tensor = input_tensor[:, 1:, :]

    # Define model parameters
    input_dim = 1  # Number of input channels
    hidden_dim = 64  # Number of hidden channels
    kernel_size = 3  # Convolution kernel size

    # Initialize ConvLSTM model
    model = ConvLSTMModel(input_dim=input_dim, hidden_dim=hidden_dim, kernel_size=kernel_size)

    # Define loss function and optimizer
    criterion = nn.MSELoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

    # Train the model
    num_epochs = 10
    for epoch in range(num_epochs):
        # Forward pass
        outputs = model(input_tensor)

        # Compute loss
        loss = criterion(outputs, target_tensor)

        # Backward pass and optimization
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        # Print progress
        print(f'Epoch [{epoch + 1}/{num_epochs}], Loss: {loss.item():.4f}')

    # Generate predictions
    predictions = model(input_tensor).detach().numpy()

    # Convert predictions to DataFrame
    predictions_df = pd.DataFrame(predictions.reshape(-1, 2), columns=['Latitude', 'Longitude'])

    # Add FIR_Date column (assuming one prediction per FIR_Date)
    predictions_df['FIR_Date'] = preprocessed_data.index[1:]

    # Reorder columns
    predictions_df = predictions_df[['FIR_Date', 'Latitude', 'Longitude']]

    # Save predictions to CSV file
    predictions_save_path = f"predictions/{os.path.splitext(os.path.basename(file_path))[0]}_combined.csv"
    predictions_df.to_csv(predictions_save_path, index=False)

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

# Train model and generate predictions for each file
for file_path in file_paths:
    print(f"Processing file: {file_path}")
    train_model_and_predict(file_path)
