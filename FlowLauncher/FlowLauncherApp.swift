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

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // If no windows are visible (or they were all closed),
            // we want SwiftUI to recreate the WindowGroup.
            // Returning true tells SwiftUI to perform its default reopen behavior.
            return true
        }
        return true
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

        let mainWindow = NSApp.windows.first { window in
            window.title == "Flow"
        } ?? NSApp.windows.first { window in
            !window.title.contains("Settings") && window.canBecomeKey
        }

        if let window = mainWindow {
            window.makeKeyAndOrderFront(nil)
        } else {
            // If no window is found (it was closed), reopen it.
            // For a SwiftUI app, if the only WindowGroup is closed, we can try to
            // reopen it by sending a 'reopen' event to the application.
            NSApp.delegate?.applicationShouldHandleReopen?(NSApp, hasVisibleWindows: false)
        }
    }
}
