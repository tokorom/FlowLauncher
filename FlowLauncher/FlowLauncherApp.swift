//
//  FlowLauncherApp.swift
//  FlowLauncher
//
//  Created by Yuta Tokoro on 2026/05/07.
//

import AppKit
import SwiftUI

extension Notification.Name {
    static let showMainWindow = Notification.Name("showMainWindow")
}

@main
struct FlowLauncherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: .showMainWindow)) { _ in
                    // This will be received by any existing window.
                    // If no window exists, we need another way to open it.
                }
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
        if let window = NSApp.windows.first(where: { $0.title == "Flow" }) {
            window.styleMask.remove(.closable)
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if isTerminating {
            return .terminateNow
        }

        // Cmd+Q closes the active window instead of quitting the app
        if let window = NSApp.keyWindow {
            window.close()
        }

        return .terminateCancel
    }

    func forceTerminate() {
        isTerminating = true
        NSApp.terminate(nil)
    }

    private func activateApp() {
        NSApp.activate(ignoringOtherApps: true)

        let mainWindow = NSApp.windows.first { window in
            window.title == "Flow"
        } ?? NSApp.windows.first { window in
            !window.title.contains("Settings") && window.canBecomeKey
        }

        if let window = mainWindow {
            window.makeKeyAndOrderFront(nil)
        } else {
            // If no window is found, we use AppleScript to simulate a click on the Dock icon,
            // which is the most reliable way to trigger SwiftUI's WindowGroup re-opening 
            // when LSUIElement is involved and all windows are closed.
            let script = "tell application \"System Events\" to tell process \"FlowLauncher\" to click UI element 1 of list 1 of application process \"Dock\""
            if let appleScript = NSAppleScript(source: script) {
                appleScript.executeAndReturnError(nil)
            }
            
            // Fallback to standard reopen
            NSApp.delegate?.applicationShouldHandleReopen?(NSApp, hasVisibleWindows: false)
        }
    }
}
