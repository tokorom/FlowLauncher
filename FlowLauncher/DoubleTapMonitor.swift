//
//  DoubleTapMonitor.swift
//  FlowLauncher
//

import AppKit

class DoubleTapMonitor {
    private var lastReleaseTime: TimeInterval = 0
    private var isWaitingForSecondRelease = false
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
        lastReleaseTime = 0
        isWaitingForSecondRelease = false
    }

    private func handleFlagsChanged(_ event: NSEvent) {
        let currentFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let targetModifier = SettingsManager.shared.hotkeyModifier.modifierFlags

        if currentFlags == targetModifier {
            // Target modifier pressed (and it's the only one)
            if !lastModifierFlags.contains(targetModifier) {
                let currentTime = ProcessInfo.processInfo.systemUptime
                if currentTime - lastReleaseTime < threshold {
                    isWaitingForSecondRelease = true
                }
            }
        } else if currentFlags.isEmpty {
            // All modifiers released
            if lastModifierFlags.contains(targetModifier) {
                if isWaitingForSecondRelease {
                    onDoubleTap()
                    reset()
                } else {
                    lastReleaseTime = ProcessInfo.processInfo.systemUptime
                }
            }
        } else {
            reset()
        }

        lastModifierFlags = currentFlags
    }
}
