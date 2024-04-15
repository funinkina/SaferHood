import SwiftUI
import CoreML

struct CriminalPrediction: View {
    // Define input data variables
    @State private var districtName: String = ""
    @State private var age: Double = 0
    @State private var caste: String = ""
    @State private var profession: String = ""
    @State private var sex: String = ""
    
    // Define output variable
    @State private var predictionResult: String = ""
    
    // Define body of the SwiftUI view
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    // Section for input fields
                    Group {
                        Text("Enter Details")
                            .font(.title2)
                            .padding(.bottom, 10)
                        
                        // District Name input
                        VStack(alignment: .leading) {
                            Text("District Name")
                                .font(.headline)
                            TextField("e.g., Example District", text: $districtName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 5)
                        }
                        
                        // Age input
                        VStack(alignment: .leading) {
                            Text("Age")
                                .font(.headline)
                            TextField("e.g., 30", value: $age, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .padding(.bottom, 5)
                        }
                        
                        // Caste input
                        VStack(alignment: .leading) {
                            Text("Caste")
                                .font(.headline)
                            TextField("e.g., Example Caste", text: $caste)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 5)
                        }
                        
                        // Profession input
                        VStack(alignment: .leading) {
                            Text("Profession")
                                .font(.headline)
                            TextField("e.g., Example Profession", text: $profession)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 5)
                        }
                        
                        // Sex input
                        VStack(alignment: .leading) {
                            Text("Sex")
                                .font(.headline)
                            TextField("e.g., Male", text: $sex)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.bottom, 5)
                        }
                    }
                    
                    // Button to run the prediction
                    Button(action: {
                        // Add prediction logic here
                    }) {
                        Text("Predict")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 20)
                    
                    if !predictionResult.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Prediction:")
                                .font(.headline)
                                .padding(.top, 15)
                            Text(predictionResult)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Criminal Prediction")
        }
    }
}

struct CriminalPrediction_Previews: PreviewProvider {
    static var previews: some View {
        CriminalPrediction()
    }
}
