//
//  AccessibilityHelper.swift
//  MyMacOsFirstApp
//
//  Created by zohaib on 10/11/2025.
//

import Foundation
import ApplicationServices

enum AccessibilityHelper {
    /// Returns true if the process is trusted for Accessibility control.
    /// If `promptIfNeeded` is true and access is not granted, macOS will show a system prompt
    /// directing the user to System Settings → Privacy & Security → Accessibility.
    static func checkAccessibility(promptIfNeeded: Bool) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: promptIfNeeded] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
}
