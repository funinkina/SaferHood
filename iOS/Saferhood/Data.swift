//
//  Data.swift
//  Saferhood
//
//  Created by Neeraj Shetkar on 07/04/24.
//

import SwiftUI
import Foundation
import SwiftData

@Model
class onDeviceData {
    let name: String
    let age: String
    let role: String
    let phone: String
    let bloodGroup: String
    let token: String
    let id: Int
    
    init(name: String, age: String, role: String, phone: String, bloodGroup: String, token: String, id: Int) {
        self.name = name
        self.age = age
        self.role = role
        self.phone = phone
        self.bloodGroup = bloodGroup
        self.token = token
        self.id = id
    }
}
