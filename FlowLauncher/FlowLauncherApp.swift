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

    func applicationDidFinishLaunching(_ notification: Notification) {
        doubleTapMonitor = DoubleTapMonitor {
            self.activateApp()
        }
    }

    private func activateApp() {
        NSApp.activate(ignoringOtherApps: true)
        // If the window is closed or hidden, we might need to make it visible
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
