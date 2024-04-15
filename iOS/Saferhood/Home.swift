//
//  Home.swift
//  SaferHood
//
//  Created by Neeraj Shetkar on 11/03/24.
//

import SwiftUI
import MapKit
import LocalAuthentication
import SwiftData

struct Home: View {
    @Environment(\.modelContext) var context
    @State private var coordinate = CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777)
    @State private var showProfile: Bool = false
    @State private var showAlerts: Bool = false
    @State private var criminalPrediction: Bool = false
    @State var camera: MapCameraPosition = .automatic
    @State var sos: Bool = false
    @StateObject var viewModel = ContentViewModel()
    @State var searchResults: [String: [MKMapItem]] = ["Police station":[], "Hospital":[]]
    @State var showPolice: Bool = false
    @State var showHospital: Bool = false
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State var id: Int = 0
    @Query var token: [onDeviceData]
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "This is for security purpose", reply: {success,authenticationError in
                if success {
                    sos = false
                    stopStreamingLocation()
                } else {
                    print("Authentication error")
                }
            })
        } else {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "This is for security purpose", reply: {success,authenticationError in
                if success {
                    sos = false
                    stopStreamingLocation()
                } else {
                    print("Some error occured")
                }
            })
        }
    }
    
    func search(for query: String, near userLocation: CLLocationCoordinate2D) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults[query] = response?.mapItems ?? []
        }
    }
    
    var body: some View {
        ZStack {
            Map {
                if let userLocation = viewModel.locationManager?.location?.coordinate {
                    Annotation("You", coordinate: userLocation, content: {
                        HStack {
                            Image(systemName: "person")
                        }
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .font(.title3)
                        .clipShape(Capsule())
                    })
                }
                if showPolice {
                    ForEach(searchResults["Police station"] ?? [], id:\.self) { police_station in
                        Marker(item: police_station)
                    }
                }
                if showHospital {
                    ForEach(searchResults["Hospital"] ?? [], id:\.self) { police_station in
                        Marker(item: police_station)
                    }
                }
            }
            .onAppear(perform: {
                viewModel.checkIfLocationIsEnabled()
                if let userLocation = viewModel.locationManager?.location?.coordinate {
                    search(for: "Police station", near: userLocation)
                    search(for: "Hospital", near: userLocation)
                }
            })
            .mapStyle(.hybrid(elevation: .realistic))
            .ignoresSafeArea()
            .safeAreaInset(edge: .top, content: {
                HStack {
                    Text("SaferHood")
                        .font(.title.bold())
                    Spacer()                    
                    Button(action: {
                        showAlerts = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                        }
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .font(.title3)
                    .clipShape(Capsule())
                    
                }
                .padding()
                .background(.ultraThinMaterial)
            })
            .safeAreaInset(edge:.bottom, content: {
                HStack {
                    Button(action: {
                        showPolice = !showPolice
                    }) {
                        HStack {
                            Image(systemName: "figure.wave.circle.fill")
                            Text("Police")
                                .font(.caption2)
                        }
                    }
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .font(.title3)
                    .clipShape(Capsule())
                    Spacer()
                    VStack {
                        if !sos {
                            Button(action: {
                                id = Int.random(in: 0..<999999)
                                startStreamingLocation()
                                sos = true
                            }) {
                                HStack {
                                    Image(systemName: "shield.righthalf.filled")
                                    Text("Help")
                                        .font(.subheadline.bold())
                                }
                            }
                            .padding(20)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .font(.title3)
                            .clipShape(Capsule())
                        } else {
                            Button(action: {
                                authenticate()
                            }) {
                                HStack {
                                    Image(systemName: "shield.righthalf.filled")
                                    Text("Stop")
                                        .font(.subheadline.bold())
                                }
                            }
                            .padding(20)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .font(.title3)
                            .clipShape(Capsule())
                        }
                    }
                    .onReceive(timer) { _ in
                        if sos {
                            Task {
                                do {
                                    _ = try await sendLocation(id: id)
                                } catch {
                                    print("Error sending location: \(error)")
                                }
                            }
                        }
                    }
                    Spacer()
                    Button(action: {
                        showHospital = !showHospital
                    }) {
                        HStack {
                            Image(systemName: "stethoscope.circle.fill")
                            Text("Hospitals")
                                .font(.caption2)
                        }
                    }
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .font(.title3)
                    .clipShape(Capsule())
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(.capsule)
                .frame(width: 375, height: 50)
            })
            .sheet(isPresented: $showAlerts) {
                InfoPageView()
            }
        }
    }
    
    func sendLocation(id: Int) async throws -> location {
        guard let userLocation = viewModel.locationManager?.location?.coordinate else {
            throw LocationError.locationUnavailable
        }
        
        var endpoint = ""
        
        if (!token.isEmpty) {
            let user = token.last!
            endpoint = "\(APIConstants.baseURL)\(userLocation.longitude)/\(userLocation.latitude)/\(user.id)"
        } else {
            endpoint = "\(APIConstants.baseURL)\(userLocation.longitude)/\(userLocation.latitude)/0"
        }
        
        
        guard let url = URL(string: endpoint) else {
            throw LocationError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let location = try decoder.decode(location.self, from: data)
        
        return location
    }

    private func startStreamingLocation() {
        timer
    }
    
    private func stopStreamingLocation() {
        timer.upstream.connect().cancel()
    }
}

enum LocationError: Error {
    case locationUnavailable
    case invalidURL
}

struct location: Codable {
    let longitude: Float
    let latitude: Float
    let id: Int
    let status: String
}

#Preview {
    Home()
}
