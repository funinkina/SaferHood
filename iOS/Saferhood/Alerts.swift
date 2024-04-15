import SwiftUI

// Define a struct for the alert data
struct AlertData: Identifiable, Codable {
    var id: Int
    var headline: String
    var description: String
    var address: String
    var street: String
    var colony: String
    var city: String
    var severity: String
}

class AlertsViewModel: ObservableObject {
    @Published var alerts: [AlertData] = []
    
    func fetchAlerts() {
        guard let url = URL(string: "\(APIConstants.baseURL)/alerts") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch data:", error?.localizedDescription ?? "Unknown error")
                return
            }
            do {
                // Decode the fetched data into an array of AlertData objects
                let fetchedAlerts = try JSONDecoder().decode([AlertData].self, from: data)
                
                // Update the alerts array in the view model
                DispatchQueue.main.async {
                    self.alerts = fetchedAlerts
                }
            } catch {
                print("Failed to decode JSON:", error.localizedDescription)
            }
        }
        task.resume()
    }
}


struct Alerts: View {
    // Initialize the view mode
    @StateObject private var viewModel = AlertsViewModel()
    var body: some View {
        NavigationView {
            List(viewModel.alerts) { alert in
                NavigationLink(destination: AlertDetail(alert: alert)) {
                    VStack(alignment: .leading) {
                        Text(alert.headline)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Alerts")
            .onAppear {
                viewModel.fetchAlerts()
            }
        }
    }
}

#Preview {
    Alerts()
}
