import SwiftUI

struct MacOSSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Titlebar") {
                Picker("Titlebar Style", selection: $viewModel.macosTitlebarStyle) {
                    Text("Native").tag("native")
                    Text("Transparent").tag("transparent")
                    Text("Tabs").tag("tabs")
                    Text("Hidden").tag("hidden")
                }

                Picker("Window Buttons", selection: $viewModel.macosWindowButtons) {
                    Text("Visible").tag("visible")
                    Text("Hidden").tag("hidden")
                }

                Picker("Proxy Icon", selection: $viewModel.macosTitlebarProxyIcon) {
                    Text("Visible").tag("visible")
                    Text("Hidden").tag("hidden")
                }
            }

            Section("Input") {
                Picker("Option as Alt", selection: $viewModel.macosOptionAsAlt) {
                    Text("Off").tag("false")
                    Text("Left").tag("left")
                    Text("Right").tag("right")
                    Text("Both").tag("true")
                }
            }

            Section("Fullscreen") {
                Picker("Non-Native Fullscreen", selection: $viewModel.macosNonNativeFullscreen) {
                    Text("Off").tag("false")
                    Text("On").tag("true")
                    Text("Visible Menu").tag("visible-menu")
                    Text("Padded Notch").tag("padded-notch")
                }
            }

            Section("Quick Terminal") {
                Picker("Position", selection: $viewModel.quickTerminalPosition) {
                    Text("Top").tag("top")
                    Text("Bottom").tag("bottom")
                    Text("Left").tag("left")
                    Text("Right").tag("right")
                    Text("Center").tag("center")
                }

                VStack(alignment: .leading) {
                    HStack {
                        Text("Animation Duration")
                        Spacer()
                        Text(String(format: "%.2fs", viewModel.quickTerminalAnimationDuration))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(value: $viewModel.quickTerminalAnimationDuration, in: 0...1)
                }

                Toggle("Auto-Hide", isOn: $viewModel.quickTerminalAutoHide)
            }

            Section("Security") {
                Toggle("Auto Secure Input", isOn: $viewModel.macosAutoSecureInput)
            }

            Section("Window") {
                Toggle("Window Shadow", isOn: $viewModel.macosWindowShadow)

                Picker("App Icon", selection: $viewModel.macosIcon) {
                    Text("Official").tag("official")
                    Text("Custom Style").tag("custom-style")
                }
            }
        }
        .formStyle(.grouped)
    }
}
