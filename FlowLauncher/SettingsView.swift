//
//  SettingsView.swift
//  FlowLauncher
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        @Bindable var settings = SettingsManager.shared
        Form {
            Section {
                HStack {
                    Text("Version")
                        .font(.headline)
                    Spacer()
                    Text(settings.appVersion)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Section("起動設定") {
                Picker("起動ホットキー", selection: $settings.hotkeyModifier) {
                    ForEach(ModifierKey.allCases) { key in
                        Text("\(key.displayString), \(key.displayString)").tag(key)
                    }
                }

                Toggle("ログイン時に自動起動", isOn: $settings.launchAtLogin)
            }

            Section {
                Button(role: .destructive) {
                    if let appDelegate = AppDelegate.instance {
                        appDelegate.forceTerminate()
                    }
                } label: {
                    Text("Quit FlowLauncher")
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 300)
    }
}

#Preview {
    SettingsView()
}
