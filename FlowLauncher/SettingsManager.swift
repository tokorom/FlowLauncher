//
//  SettingsManager.swift
//  FlowLauncher
//

import Observation
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

@Observable
@MainActor
class SettingsManager {
    static let shared = SettingsManager()

    var hotkeyModifier: ModifierKey {
        get {
            access(keyPath: \.hotkeyModifier)
            return ModifierKey(rawValue: UserDefaults.standard.string(forKey: "hotkeyModifier") ?? "") ?? .control
        }
        set {
            withMutation(keyPath: \.hotkeyModifier) {
                UserDefaults.standard.set(newValue.rawValue, forKey: "hotkeyModifier")
            }
        }
    }

    var launchAtLogin: Bool {
        get {
            access(keyPath: \.launchAtLogin)
            return UserDefaults.standard.bool(forKey: "launchAtLogin")
        }
        set {
            withMutation(keyPath: \.launchAtLogin) {
                UserDefaults.standard.set(newValue, forKey: "launchAtLogin")
                updateLaunchAtLogin(newValue)
            }
        }
    }

    private init() {}

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
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
