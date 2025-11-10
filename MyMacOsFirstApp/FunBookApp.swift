//
//  MouseMoverApp.swift
//  MyMacOsFirstApp
//
//  Created by zohaib on 10/11/2025.
//


import SwiftUI

@main
struct FunBookApp: App {
    @StateObject private var controller = InputController() // ✅ same class name

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controller) // ✅ this line is REQUIRED
                .frame(minWidth: 420, minHeight: 220)
        }
    }
}
