//
//  MouseController.swift
//  MyMacOsFirstApp
//
//  Created by zohaib on 10/11/2025.
//

import SwiftUI
import Cocoa
import CoreGraphics
import Combine 


final class MouseController: ObservableObject {
    // Public state bound to UI
    @Published private(set) var isRunning = false
    @Published private(set) var lastMovedDescription: String = "Never"
    @Published var interval: TimeInterval = 5.0
    @Published var pattern: MovementPattern = .jitter

    // Private timer
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.mousemover.timer")
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
        // Immediate move to indicate start
        moveOnce()
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
            self?.moveOnce()
        }
        timer?.resume()
    }

    func moveOnce() {
        // Get current mouse position in global coordinates
        // NSEvent.mouseLocation returns (x,y) in screen coords with origin at bottom-left relative to main display origin.
        let current = NSEvent.mouseLocation

        let next: CGPoint
        switch pattern {
        case .jitter:
            let dx = CGFloat.random(in: -8...8)
            let dy = CGFloat.random(in: -8...8)
            next = CGPoint(x: current.x + dx, y: current.y + dy)
        case .circle:
            // small circle around current position
            circleAngle += CGFloat(Double.pi / 8.0)
            let radius: CGFloat = 20
            let x = current.x + cos(circleAngle) * radius
            let y = current.y + sin(circleAngle) * radius
            next = CGPoint(x: x, y: y)
        case .horizontal:
            // move right a little, wrap back
            let dx: CGFloat = 20
            next = CGPoint(x: current.x + dx, y: current.y)
        }

        postMouseMove(to: next)
        DispatchQueue.main.async {
            self.lastMovedDescription = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        }
    }

    private func postMouseMove(to point: CGPoint) {
        // Create and post a CGEvent mouse-move
        if let move = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left) {
            move.post(tap: .cghidEventTap)
        } else {
            // fallback: try warp cursor (rarely needed)
            CGWarpMouseCursorPosition(point)
        }
    }
}
