//
//  ContentView.swift
//  SaferHood
//
//  Created by Neeraj Shetkar on 11/03/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        LoginView()
    }
}

#Preview {
    ContentView()
}
