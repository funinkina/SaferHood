//
//  Alerts.swift
//  SaferHood
//
//  Created by Neeraj Shetkar on 11/03/24.
//

import SwiftUI

struct InfoPageView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("About Saferhood")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text("Saferhood is an SOS application designed to enhance your safety and provide assistance in emergency situations. It offers the following key features:")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                Group {
                    Text("SOS Feature")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("By pressing the SOS button, Saferhood starts streaming your location to the control panel, allowing you to seek help from the Karnataka police. This feature can be vital in emergency situations, as it ensures your location is constantly updated for the police to track.")
                        .font(.body)
                        .padding(.bottom, 10)
                    
                    Text("Biometric Authentication")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("To stop the SOS feature, use the biometric authentication available on your phone (such as fingerprint or face ID). This provides an extra layer of security and ensures that only you can stop the SOS feature.")
                        .font(.body)
                        .padding(.bottom, 10)
                    
                    Text("Nearby Police Stations and Hospitals")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("With a single click, you can find nearby police stations and hospitals. This feature is designed to quickly guide you to the nearest location where you can find help.")
                        .font(.body)
                }
                .padding(.bottom, 10)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("Info", displayMode: .inline)
    }
}

#Preview {
    InfoPageView()
}
