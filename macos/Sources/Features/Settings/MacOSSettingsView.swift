import SwiftUI

struct MacOSSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Titlebar") {
                Picker("Titlebar Style", selection: viewModel.macosTitlebarStyle.binding) {
                    Text("Native").tag("native")
                    Text("Transparent").tag("transparent")
                    Text("Tabs").tag("tabs")
                    Text("Hidden").tag("hidden")
                }

                Picker("Window Buttons", selection: viewModel.macosWindowButtons.binding) {
                    Text("Visible").tag("visible")
                    Text("Hidden").tag("hidden")
                }

                Picker("Proxy Icon", selection: viewModel.macosTitlebarProxyIcon.binding) {
                    Text("Visible").tag("visible")
                    Text("Hidden").tag("hidden")
                }
            }

            Section("Input") {
                Picker("Option as Alt", selection: viewModel.macosOptionAsAlt.binding) {
                    Text("Off").tag("false")
                    Text("Left").tag("left")
                    Text("Right").tag("right")
                    Text("Both").tag("true")
                }
            }

            Section("Fullscreen") {
                Picker("Non-Native Fullscreen", selection: viewModel.macosNonNativeFullscreen.binding) {
                    Text("Off").tag("false")
                    Text("On").tag("true")
                    Text("Visible Menu").tag("visible-menu")
                    Text("Padded Notch").tag("padded-notch")
                }
            }

            Section("Quick Terminal") {
                Picker("Position", selection: viewModel.quickTerminalPosition.binding) {
                    Text("Top").tag("top")
                    Text("Bottom").tag("bottom")
                    Text("Left").tag("left")
                    Text("Right").tag("right")
                    Text("Center").tag("center")
                }

                SliderSetting(
                    "Animation Duration",
                    setting: viewModel.quickTerminalAnimationDuration,
                    range: 0...1
                ) { String(format: "%.2fs", $0) }

                Toggle("Auto-Hide", isOn: viewModel.quickTerminalAutoHide.boolBinding)
            }

            Section("Security") {
                Toggle("Auto Secure Input", isOn: viewModel.macosAutoSecureInput.boolBinding)
            }

            Section("Window") {
                Toggle("Window Shadow", isOn: viewModel.macosWindowShadow.boolBinding)

                Picker("App Icon", selection: viewModel.macosIcon.binding) {
                    Text("Official").tag("official")
                    Text("Custom Style").tag("custom-style")
                }
            }
        }
        .formStyle(.grouped)
    }
}
