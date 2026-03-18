import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section("Font") {
                HStack {
                    Text("Font Family")
                    Spacer()
                    TextField("e.g. JetBrains Mono", text: viewModel.fontFamily.binding)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 200)
                }

                NumericSetting("Font Size", setting: viewModel.fontSize, range: 1...200)

                Toggle("Thicken Font Strokes", isOn: viewModel.fontThicken.boolBinding)
            }

            Section("Cursor") {
                Picker("Cursor Style", selection: viewModel.cursorStyle.binding) {
                    Text("Block").tag("block")
                    Text("Bar").tag("bar")
                    Text("Underline").tag("underline")
                }
                .pickerStyle(.segmented)

                Picker("Cursor Blink", selection: viewModel.cursorStyleBlink.binding) {
                    Text("Default").tag("")
                    Text("On").tag("true")
                    Text("Off").tag("false")
                }
            }

            Section("Terminal") {
                Picker("Shell Integration", selection: viewModel.shellIntegration.binding) {
                    Text("Detect").tag("detect")
                    Text("None").tag("none")
                    Text("Fish").tag("fish")
                    Text("Zsh").tag("zsh")
                    Text("Bash").tag("bash")
                    Text("Elvish").tag("elvish")
                }

                Picker("Copy on Select", selection: viewModel.copyOnSelect.binding) {
                    Text("Off").tag("false")
                    Text("On").tag("true")
                    Text("Clipboard").tag("clipboard")
                }

                Toggle("Hide Mouse While Typing", isOn: viewModel.mouseHideWhileTyping.boolBinding)
                Toggle("Focus Follows Mouse", isOn: viewModel.focusFollowsMouse.boolBinding)
            }

            Section("Window") {
                Picker("Confirm Before Closing", selection: viewModel.confirmCloseSurface.binding) {
                    Text("Yes").tag("true")
                    Text("No").tag("false")
                    Text("Always").tag("always")
                }

                Toggle("Quit After Last Window Closed", isOn: viewModel.quitAfterLastWindowClosed.boolBinding)
            }
        }
        .formStyle(.grouped)
    }
}
