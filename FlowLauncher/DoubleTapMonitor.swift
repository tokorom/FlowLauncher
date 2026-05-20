//
//  DoubleTapMonitor.swift
//  FlowLauncher
//

import AppKit

class DoubleTapMonitor {
    private let threshold: TimeInterval = 0.4
    private let onDoubleTap: () -> Void

    private var hotkeyState: HotkeyState = .idle

    init(onDoubleTap: @escaping () -> Void) {
        self.onDoubleTap = onDoubleTap
        setupMonitor()
    }

    private func setupMonitor() {
        // Global monitors
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
        }
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] _ in
            self?.reset()
        }

        // Local monitors
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
            return event
        }
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] event in
            self?.reset()
            return event
        }
    }

    func reset() {
        hotkeyState = .idle
    }

    private func handleFlagsChanged(_ event: NSEvent) {
        let currentFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let targetModifier = SettingsManager.shared.hotkeyModifier.modifierFlags

        switch hotkeyState {
        case .idle:
            if currentFlags == targetModifier {
                hotkeyState = .firstPressed(firstPressedTime: ProcessInfo.processInfo.systemUptime)
            } else if !currentFlags.isEmpty {
                reset()
            }
        case .firstPressed(let firstPressedTime):
            if currentFlags == targetModifier {
                if ProcessInfo.processInfo.systemUptime - firstPressedTime < threshold {
                    hotkeyState = .secondPressed(firstPressedTime: firstPressedTime)
                } else {
                    hotkeyState = .firstPressed(firstPressedTime: ProcessInfo.processInfo.systemUptime)
                }
            } else if !currentFlags.isEmpty {
                reset()
            }
        case .secondPressed(let firstPressedTime):
            if currentFlags.isEmpty {
                if ProcessInfo.processInfo.systemUptime - firstPressedTime < threshold {
                    onDoubleTap()
                    reset()
                } else {
                    hotkeyState = .firstPressed(firstPressedTime: ProcessInfo.processInfo.systemUptime)
                }
            } else {
                reset()
            }
        }
    }
}

enum HotkeyState {
    case idle
    case firstPressed(firstPressedTime: TimeInterval)
    case secondPressed(firstPressedTime: TimeInterval)
}
