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
        if let window = NSApp.keyWindow {
            window.orderOut(nil)
        }

        return .terminateCancel
    }

    func forceTerminate() {
        isTerminating = true
        NSApp.terminate(nil)
    }

    private func activateApp() {
        let mainWindow = findMainWindow()

        if let window = mainWindow, NSApp.isActive && window.isVisible && window.isKeyWindow {
            window.orderOut(nil)
            return
        }

        NSApp.unhide(nil)
        NSApp.activate(ignoringOtherApps: true)

        if let window = mainWindow {
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        } else {
            // If no window is found, trigger a reopen event which should show the main WindowGroup.
            _ = NSApp.delegate?.applicationShouldHandleReopen?(NSApp, hasVisibleWindows: false)
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
}
