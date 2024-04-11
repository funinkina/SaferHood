//
//  Register.swift
//  Saferhood
//
//  Created by Neeraj Shetkar on 07/04/24.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var selectedBloodGroupIndex = 0
    let bloodGroups = ["Choose Blood Group", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    
    var body: some View {
        VStack {
            Image("icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Text("Register")
                .font(.title.bold())
            
            VStack(spacing: 20) {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8.0)
                
                TextField("Age", text: $age)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8.0)
                    .keyboardType(.numberPad)
                
                TextField("Phone", text: $phone)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8.0)
                    .keyboardType(.phonePad)
                
                TextField("Email Address", text: $email)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8.0)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8.0)
                
                Picker("Blood Group", selection: $selectedBloodGroupIndex) {
                    ForEach(0..<bloodGroups.count) { index in
                        Text(bloodGroups[index])
                            .foregroundColor(index == 0 ? .gray : .black)
                            .tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8.0)
                
                Button(action: {
                    registerUser { result in
                        switch result {
                        case .success(let response):
                            print("Registration successful. Response: \(response)")
                            dismiss()
                        case .failure(let error):
                            print("Registration failed. Error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Register")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8.0)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .padding()
    }
    
    func registerUser(completion: @escaping (Result<String, Error>) -> Void) {
        guard selectedBloodGroupIndex != 0 else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Please choose a blood group"])))
            return
        }
        
        // Construct user data object
        let userData = UserData(name: name, age: age, role: "user", phone: phone, bloodGroup: bloodGroups[selectedBloodGroupIndex], token: "", id: 0)
        
        // Create a dictionary representing the user data including the password
        let userDataDict: [String: Any] = [
            "name": userData.name,
            "age": userData.age,
            "role": userData.role,
            "phone": userData.phone,
            "bloodGroup": userData.bloodGroup,
            "password": password,
            "email": email
        ]
        
        // Convert user data dictionary to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userDataDict) else {
            completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to encode user data"])))
            return
        }
        
        // Construct URL for the registration endpoint
        guard let url = URL(string: APIConstants.baseURL + "register") else {
            completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create a POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            if (200..<300).contains(httpResponse.statusCode) {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    completion(.success(responseString))
                } else {
                    completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
            }
        }
        task.resume()
    }
}


#Preview {
    RegistrationView()
}
