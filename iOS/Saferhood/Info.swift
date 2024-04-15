//
//  Alerts.swift
//  SaferHood
//
//  Created by Neeraj Shetkar on 11/03/24.
//

import SwiftUI


struct InfoPageView: View {
    
    var body: some View {
        ZStack {
            TabView {
                Alerts()
                    .tabItem {
                        Label("Alerts", systemImage: "tray.and.arrow.down.fill")
                    }
                CriminalPrediction()
                    .tabItem {
                        Label("Crime Prediction", systemImage: "person.crop.circle.fill")
                    }
                About()
                    .tabItem {
                        Label("About", systemImage: "info.circle")
                    }
                Profile()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
        }
    }
}

struct AlertDetail: View {
    var alert: AlertData
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                AddressDetail(label: "Address", value: alert.address)
                AddressDetail(label: "Colony", value: alert.colony)
                AddressDetail(label: "Street", value: alert.street)
                AddressDetail(label: "City", value: alert.city)
                AddressDetail(label: "Severity", value: alert.severity)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding()
        }
        .navigationTitle(alert.headline)
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(alert.description)
            }
            .frame(width: 325)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .padding()
        }
        Spacer()
    }
}

struct AddressDetail: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.blue)
                .font(.headline)
            Spacer()
            Text(value)
                .foregroundColor(.black)
                .font(.body)
        }
    }
}

#Preview {
    InfoPageView()
}
