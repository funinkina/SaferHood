//
//  SignIn.swift
//  Saferhood
//
//  Created by Neeraj Shetkar on 07/04/24.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) var context
    @Environment (\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isRegisterPagePresented = false
    @Query var token: [onDeviceData]
    @State var showHome: Bool = false
    
    var body: some View {
        if !showHome {
            VStack {
                Image("icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .padding()
                
                Text("Sign In")
                    .font(.title.bold())
                
                
                VStack(spacing: 20) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8.0)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8.0)
                    
                    Button(action: {
                        loginUser(username: username, password: password) { result in
                            switch result {
                            case .success(let userData):
                                print("Login successful. User data: \(userData)")
                            case .failure(let error):
                                print("Login failed. Error: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8.0)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                
                Button(action: {
                        isRegisterPagePresented = true
                    }) {
                        Text("Register")
                            .foregroundColor(.blue)
                            .padding(.bottom, 20)
                    }
                    .sheet(isPresented: $isRegisterPagePresented) {
                        RegistrationView()
                    }
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
            }
            .padding()
            .onAppear() {
                isTokenValid(token: token) { isValid, error in
                    if let error = error {
                        print("Error validating token: \(error.localizedDescription)")
                        return
                    }
                    showHome = isValid
                }
            }
        } else {
            Home()
        }
        
    }

    func loginUser(username: String, password: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        let apiUrl = URL(string: APIConstants.baseURL + "login")!
        let requestBody: [String: Any] = [
            "username": username,
            "password": password
        ]
        guard let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(APIError.invalidRequestBody))
            return
        }
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBodyData
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            guard let responseData = data else {
                completion(.failure(APIError.emptyResponseData))
                return
            }
            do {
                let userData = try JSONDecoder().decode(UserData.self, from: responseData)
                let token = onDeviceData(name: userData.name, age: userData.age, role: userData.role, phone: userData.phone, bloodGroup: userData.bloodGroup, token: userData.token, id: userData.id)
                context.insert(token)
                try! context.save()
                showHome = true
                completion(.success(userData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func isTokenValid(token: [onDeviceData], completion: @escaping (Bool, Error?) -> Void) {
        let apiUrl = URL(string: "\(APIConstants.baseURL)validate_token")!
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let userToken = token.last?.token else {
            completion(false, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Token is empty"]))
            return
        }
        
        let requestBody: [String: Any] = ["token": userToken]
        guard let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(false, NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request body"]))
            return
        }
        request.httpBody = requestBodyData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(false, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid token"]))
                return
            }
            
            completion(true, nil)
        }.resume()
    }

    enum APIError: Error {
        case invalidRequestBody
        case invalidResponse
        case emptyResponseData
    }
}

struct UserData: Codable {
    let name: String
    let age: String
    let role: String
    let phone: String
    let bloodGroup: String
    let token: String
    let id: Int
}

#Preview {
    LoginView()
}
