//
//  DoubleTapMonitor.swift
//  FlowLauncher
//

import AppKit

class DoubleTapMonitor {
    private var lastEventTime: TimeInterval = 0
    private var lastModifierFlags: NSEvent.ModifierFlags = []
    private let threshold: TimeInterval = 0.4
    private let onDoubleTap: () -> Void

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

    private func reset() {
        lastEventTime = 0
    }

    private func handleFlagsChanged(_ event: NSEvent) {
        let currentFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let targetModifier = SettingsManager.shared.hotkeyModifier.modifierFlags

        // Check if the target modifier was just pressed (and no other modifiers are active)
        if currentFlags == targetModifier {
            if !lastModifierFlags.contains(targetModifier) {
                let currentTime = ProcessInfo.processInfo.systemUptime
                if currentTime - lastEventTime < threshold {
                    onDoubleTap()
                    reset()
                } else {
                    lastEventTime = currentTime
                }
            }
        } else if !currentFlags.isEmpty {
            // Any other modifier combination resets the state
            reset()
        }

        lastModifierFlags = currentFlags
    }
}
