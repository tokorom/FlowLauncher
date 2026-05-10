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

    var body: some Scene {
        WindowGroup {
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

    private func setupMainWindow() {
        // Find the main window and disable its close button
        DispatchQueue.main.async {
            if let window = NSApp.windows.first(where: { $0.title == "Flow" }) {
                window.styleMask.remove(.closable)
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

        // Find the main window (identified by title "Flow" or just the first non-settings window)
        let mainWindow = NSApp.windows.first { window in
            window.title == "Flow" || !(window.contentViewController is NSHostingController<SettingsView>)
        }

        if let window = mainWindow {
            window.makeKeyAndOrderFront(nil)
        }
    }
}
