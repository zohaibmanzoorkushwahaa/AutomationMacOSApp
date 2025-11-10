//
//  ContentView.swift
//  MyMacOsFirstApp
//
//  Created by zohaib on 10/11/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var controller: InputController

    var body: some View {
        VStack(spacing: 16) {
            Text("Fun Controller")
                .font(.headline)

            HStack {
                Text("Interval:")
                Slider(value: $controller.interval, in: 1...30, step: 1)
                Text("\(Int(controller.interval))s")
            }

            Picker("Guess Pattern:", selection: $controller.pattern) {
                ForEach(MovementPattern.allCases, id: \.self) {
                    Text($0.displayName)
                }
            }
            .pickerStyle(.segmented)

            Picker("Select Char:", selection: $controller.keyboardAction) {
                ForEach(KeyboardAction.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }

            if controller.keyboardAction == .custom {
                TextField("Randon key (a-z, space)", text: $controller.customKey)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
            }

            Text("Last Action: \(controller.lastActionDescription)")
                .font(.footnote)

            HStack {
                Button("Start") { controller.startIfAllowed() }
                    .keyboardShortcut("s", modifiers: [.command])
                Button("Stop") { controller.stop() }
                    .keyboardShortcut("t", modifiers: [.command])
            }
        }
        .padding(24)
        .frame(width: 420)
    }
}


struct PermissionsInfoView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Accessibility Permission")
                .font(.title3)
                .bold()
            Text("Access to Fun")
                .font(.body)
            Button("Open System Settings") {
                // Open the Accessibility Privacy pane (works on macOS Ventura+)
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
        .frame(minWidth: 420, minHeight: 220)
    }
}
