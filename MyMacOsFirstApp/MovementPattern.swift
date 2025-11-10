//
//  MovementPattern.swift
//  MyMacOsFirstApp
//
//  Created by zohaib on 10/11/2025.
//


import SwiftUI
import Combine
import Cocoa
import CoreGraphics

/// Supported movement and keyboard patterns
enum MovementPattern: CaseIterable, Equatable {
    case jitter, circle, horizontal

    var displayName: String {
        switch self {
        case .jitter: return "Jitter"
        case .circle: return "Circle"
        case .horizontal: return "Horizontal"
        }
    }
}

enum KeyboardAction: String, CaseIterable, Equatable {
    case none = "None"
    case space = "Space"
    case enter = "Enter"
    case a = "A"
    case b = "B"
    case custom = "Custom"
}

final class InputController: ObservableObject {
    // Published properties
    @Published private(set) var isRunning = false
    @Published private(set) var lastActionDescription: String = "Never"
    @Published var interval: TimeInterval = 5.0
    @Published var pattern: MovementPattern = .jitter
    @Published var keyboardAction: KeyboardAction = .none
    @Published var customKey: String = ""

    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.mousekeyboard.timer")
    private var circleAngle: CGFloat = 0

    func startIfAllowed() {
        if AccessibilityHelper.checkAccessibility(promptIfNeeded: true) {
            start()
        }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        scheduleTimer()
        performAction() // immediate
    }

    func stop() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }

    private func scheduleTimer() {
        timer?.cancel()
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now() + interval, repeating: interval)
        timer?.setEventHandler { [weak self] in
            self?.performAction()
        }
        timer?.resume()
    }

    private func performAction() {
        moveMouseOnce()
        if keyboardAction != .none {
            pressKey()
        }

        DispatchQueue.main.async {
            self.lastActionDescription = DateFormatter.localizedString(
                from: Date(),
                dateStyle: .none,
                timeStyle: .medium
            )
        }
    }

    // MARK: - Mouse Movement
    private func moveMouseOnce() {
        let current = NSEvent.mouseLocation
        let next: CGPoint

        switch pattern {
        case .jitter:
            let dx = CGFloat.random(in: -8...8)
            let dy = CGFloat.random(in: -8...8)
            next = CGPoint(x: current.x + dx, y: current.y + dy)

        case .circle:
            circleAngle += CGFloat(Double.pi / 8.0)
            let radius: CGFloat = 20
            let x = current.x + cos(circleAngle) * radius
            let y = current.y + sin(circleAngle) * radius
            next = CGPoint(x: x, y: y)

        case .horizontal:
            let dx: CGFloat = 20
            next = CGPoint(x: current.x + dx, y: current.y)
        }

        if let move = CGEvent(mouseEventSource: nil,
                              mouseType: .mouseMoved,
                              mouseCursorPosition: next,
                              mouseButton: .left) {
            move.post(tap: .cghidEventTap)
        }
    }

    // MARK: - Keyboard Presses
    private func pressKey() {
        let keyCode: CGKeyCode?

        switch keyboardAction {
        case .space:
            keyCode = 49
        case .enter:
            keyCode = 36
        case .a:
            keyCode = 0
        case .b:
            keyCode = 11
        case .custom:
            keyCode = keyCodeFor(customKey.lowercased())
        case .none:
            return
        }

        guard let code = keyCode else { return }

        let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: false)
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func keyCodeFor(_ key: String) -> CGKeyCode? {
        switch key {
        case "a": return 0
        case "b": return 11
        case "c": return 8
        case "d": return 2
        case "e": return 14
        case "f": return 3
        case "g": return 5
        case "h": return 4
        case "i": return 34
        case "j": return 38
        case "k": return 40
        case "l": return 37
        case "m": return 46
        case "n": return 45
        case "o": return 31
        case "p": return 35
        case "q": return 12
        case "r": return 15
        case "s": return 1
        case "t": return 17
        case "u": return 32
        case "v": return 9
        case "w": return 13
        case "x": return 7
        case "y": return 16
        case "z": return 6
        case " ": return 49
        default:
            return nil
        }
    }
}
