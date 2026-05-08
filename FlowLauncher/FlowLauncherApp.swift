//
//  FlowLauncherApp.swift
//  FlowLauncher
//
//  Created by Yuta Tokoro on 2026/05/07.
//

import SwiftUI

@main
struct FlowLauncherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var doubleTapMonitor: DoubleTapMonitor?
    private var isTerminating = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        doubleTapMonitor = DoubleTapMonitor {
            self.activateApp()
        }

        setupMainWindow()
    }

    private func setupMainWindow() {
        // Find the main window and disable its close button
        DispatchQueue.main.async {
            if let window = NSApp.windows.first(where: { $0.title == "Flow" }) {
                window.standardButton(.closeButton)?.isEnabled = false
            }
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
        // If the window is closed or hidden, we might need to make it visible
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
