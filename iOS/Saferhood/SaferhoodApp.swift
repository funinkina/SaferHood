//
//  SaferHoodApp.swift
//  SaferHood
//
//  Created by Neeraj Shetkar on 11/03/24.
//

import SwiftUI
import SwiftData

@main
struct SaferHoodApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [onDeviceData.self])
    }
}
