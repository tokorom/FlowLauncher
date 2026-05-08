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
        // Global monitor for when the app is in background
        NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown]) { [weak self] event in
            self?.handleEvent(event)
        }

        // Local monitor for when the app is in foreground
        NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged, .keyDown]) { [weak self] event in
            self?.handleEvent(event)
            return event
        }
    }

    private func handleEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            // Any key press invalidates the double-tap sequence
            lastEventTime = 0
            return
        }

        if event.type == .flagsChanged {
            let targetModifier = SettingsManager.shared.hotkeyModifier.modifierFlags
            let currentFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

            // Check if the target modifier was just pressed (and no other modifiers are active)
            if currentFlags == targetModifier && !lastModifierFlags.contains(targetModifier) {
                let currentTime = ProcessInfo.processInfo.systemUptime
                if currentTime - lastEventTime < threshold {
                    onDoubleTap()
                    lastEventTime = 0  // Reset after trigger
                } else {
                    lastEventTime = currentTime
                }
            }

            lastModifierFlags = currentFlags
        }
    }
}
