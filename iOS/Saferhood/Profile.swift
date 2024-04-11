//
//  Profile.swift
//  SaferHood
//
//  Created by Neeraj Shetkar on 11/03/24.
//

import SwiftUI
import SwiftData

struct Profile: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    @Query var token: [onDeviceData]
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(5)
                        .foregroundColor(.white)
                        .font(.title2.bold())
                        .background(Color.blue)
                        .clipShape(Circle())
                    
                    Text("Profile")
                        .font(.title.bold())
                        .foregroundColor(.blue)
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .padding(5)
                            .foregroundColor(.white)
                            .font(.title2.bold())
                            .background(Color.red)
                            .clipShape(Circle())
                            .accessibility(label: Text("Close"))
                    }
                }
                .padding()
                
                if let user = token.last {
                    VStack(alignment: .leading, spacing: 10) {
                        ProfileDetail(label: "Name", value: user.name)
                        ProfileDetail(label: "Age", value: user.age)
                        ProfileDetail(label: "Role", value: user.role)
                        ProfileDetail(label: "Phone", value: user.phone)
                        ProfileDetail(label: "Blood Group", value: user.bloodGroup)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding()
                } else {
                    Text("User data not available")
                        .foregroundColor(.gray)
                        .italic()
                }
                Spacer()
                
                HStack {
                    Image(systemName: "arrow.up.left.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(5)
                    Text("Logout")
                }
                .padding()
                .foregroundColor(.white)
                .font(.title2.bold())
                .background(Color.blue)
                .clipShape(Capsule())
            }
        }
    }

    struct ProfileDetail: View {
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

}

#Preview {
    Profile()
}
