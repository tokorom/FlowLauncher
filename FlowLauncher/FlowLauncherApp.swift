//
//  FlowLauncherApp.swift
//  FlowLauncher
//
//  Created by Yuta Tokoro on 2026/05/07.
//

import AppKit
import SwiftUI

@main
struct FlowLauncherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)

        Settings {
            SettingsView()
        }
    }

    func openMainWindow() {
        openWindow(id: "main")
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static var instance: AppDelegate?

    private var doubleTapMonitor: DoubleTapMonitor?
    private var isTerminating = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.instance = self

        doubleTapMonitor = DoubleTapMonitor {
            self.activateApp()
        }

        setupMainWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Trigger SwiftUI to show the window.
            // For SwiftUI apps, if we return true, it usually re-opens the main window group.
            return true
        }
        return true
    }

    private func setupMainWindow() {
        // Find the main window and disable its close button
        DispatchQueue.main.async {
            self.applyWindowSettings()
        }
    }

    private func applyWindowSettings() {
        if let window = findMainWindow() {
            window.styleMask.remove(.closable)
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if isTerminating {
            return .terminateNow
        }

        // Cmd+Q hides the active window instead of quitting the app.
        // We use orderOut instead of close to keep the window in memory so it can be reopened quickly.
        hideApp()

        return .terminateCancel
    }

    func forceTerminate() {
        isTerminating = true
        NSApp.terminate(nil)
    }

    func hideApp() {
        guard let window = findMainWindow() else {
            return
        }

        window.orderOut(nil)
    }

    private func shouldSendToFront() -> Bool {
        if !NSApp.isActive {
            return true
        }

        guard let window = findMainWindow() else {
            return true
        }

        if !window.isOnActiveSpace {
            return true
        }

        if !window.isVisible {
            return true
        }

        if !window.isKeyWindow {
            return true
        }

        return false
    }

    private func sendToFront() {
        guard let window = findMainWindow() else {
            openMainWindow()
            return
        }

        window.collectionBehavior.insert(.moveToActiveSpace)
        NSApp.unhide(nil)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func activateApp() {
        if shouldSendToFront() {
            sendToFront()
        } else {
            hideApp()
        }
    }

    private func findMainWindow() -> NSWindow? {
        // Try to find the main window by title "Flow" first.
        // In SwiftUI, the main WindowGroup window usually has the app's display name as its title.
        return NSApp.windows.first { window in
            window.title == "Flow"
        }
        ?? NSApp.windows.first { window in
            // Fallback: search for a window that is likely NOT the settings window.
            let t = window.title
            return !t.contains("Settings") && !t.contains("Preferences") && !t.contains("設定") && window.canBecomeKey
        }
    }

    private func openMainWindow() {
        AppDelegate.instance?.openMainWindow()
    }
}
