import SwiftUI

struct AdvancedSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Updates") {
                Picker("Auto Update", selection: $viewModel.autoUpdate) {
                    Text("Off").tag("off")
                    Text("Check").tag("check")
                    Text("Download").tag("download")
                }

                Picker("Update Channel", selection: $viewModel.autoUpdateChannel) {
                    Text("Stable").tag("stable")
                    Text("Tip").tag("tip")
                }
            }

            Section("Session") {
                Picker("Window Save State", selection: $viewModel.windowSaveState) {
                    Text("Default").tag("default")
                    Text("Never").tag("never")
                    Text("Always").tag("always")
                }
            }

            Section("Configuration") {
                Button("Open Config in Editor") {
                    Ghostty.App.openConfig()
                }

                Button("Reload Configuration") {
                    guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
                    delegate.reloadConfig(nil)
                }

                if let path = ConfigFileEditor.configFilePath() {
                    HStack {
                        Text("Config File")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(path)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}
