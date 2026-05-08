//
//  KeyCaptureView.swift
//  FlowLauncher
//
//  Created by Yuta Tokoro on 2026/05/07.
//

import AppKit
import SwiftUI

struct KeyCaptureView: NSViewRepresentable {
    var isEnabled = true
    var onKeyDown: (NSEvent) -> Bool

    func makeNSView(context: Context) -> KeyCaptureNSView {
        let view = KeyCaptureNSView()
        view.isEnabled = isEnabled
        view.onKeyDown = onKeyDown
        return view
    }

    func updateNSView(_ nsView: KeyCaptureNSView, context: Context) {
        nsView.isEnabled = isEnabled
        nsView.onKeyDown = onKeyDown

        if isEnabled {
            nsView.reclaimFocus()
        }
    }
}

final class KeyCaptureNSView: NSView {
    var isEnabled = true
    var onKeyDown: ((NSEvent) -> Bool)?
    private var localKeyDownMonitor: Any?

    override var acceptsFirstResponder: Bool {
        true
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        if window == nil {
            removeLocalKeyDownMonitor()
            return
        }

        installLocalKeyDownMonitorIfNeeded()
        reclaimFocus()
    }

    func reclaimFocus() {
        Task { @MainActor in
            window?.makeFirstResponder(self)
        }
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        super.mouseDown(with: event)
    }

    override func keyDown(with event: NSEvent) {
        guard onKeyDown?(event) == true else {
            super.keyDown(with: event)
            return
        }
    }

    private func installLocalKeyDownMonitorIfNeeded() {
        guard localKeyDownMonitor == nil else {
            return
        }

        localKeyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else {
                return event
            }

            guard self.isEnabled,
                event.window == self.window
            else {
                return event
            }

            return self.onKeyDown?(event) == true ? nil : event
        }
    }

    private func removeLocalKeyDownMonitor() {
        guard let localKeyDownMonitor else {
            return
        }

        NSEvent.removeMonitor(localKeyDownMonitor)
        self.localKeyDownMonitor = nil
    }
}
