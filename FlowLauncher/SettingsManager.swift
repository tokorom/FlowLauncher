//
//  SettingsManager.swift
//  FlowLauncher
//

import ServiceManagement
import SwiftUI

enum ModifierKey: String, CaseIterable, Identifiable {
    case control = "Control"
    case shift = "Shift"
    case option = "Option"
    case command = "Command"

    var id: String { rawValue }

    var modifierFlags: NSEvent.ModifierFlags {
        switch self {
        case .control: return .control
        case .shift: return .shift
        case .option: return .option
        case .command: return .command
        }
    }

    var displayString: String {
        switch self {
        case .control: return "⌃ Control"
        case .shift: return "⇧ Shift"
        case .option: return "⌥ Option"
        case .command: return "⌘ Command"
        }
    }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @AppStorage("hotkeyModifier") var hotkeyModifier: ModifierKey = .control
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false {
        didSet {
            updateLaunchAtLogin()
        }
    }

    private init() {}

    func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
        }
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
