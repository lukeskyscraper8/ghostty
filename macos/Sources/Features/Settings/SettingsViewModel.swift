import SwiftUI
import Combine
import GhosttyKit

/// View model for the settings UI. Reads current values from the Ghostty config
/// and writes changes to the config file, triggering a reload.
class SettingsViewModel: ObservableObject {
    // MARK: - General Settings

    // font-family is a RepeatableString (not readable via C API), so we read from config file
    @Published var fontFamily: String = "" { didSet { saveIfChanged(oldValue, fontFamily, key: "font-family") } }
    // font-size is f32
    @Published var fontSize: Double = 13 { didSet { saveIfChanged(oldValue, fontSize, key: "font-size") } }
    // cursor-style is an enum
    @Published var cursorStyle: String = "block" { didSet { saveIfChanged(oldValue, cursorStyle, key: "cursor-style") } }
    // cursor-style-blink is ?bool
    @Published var cursorStyleBlink: String = "" { didSet { saveIfChanged(oldValue, cursorStyleBlink, key: "cursor-style-blink") } }
    @Published var mouseHideWhileTyping: Bool = false { didSet { saveIfChanged(oldValue, mouseHideWhileTyping, key: "mouse-hide-while-typing") } }
    // copy-on-select is an enum
    @Published var copyOnSelect: String = "false" { didSet { saveIfChanged(oldValue, copyOnSelect, key: "copy-on-select") } }
    // shell-integration is an enum
    @Published var shellIntegration: String = "detect" { didSet { saveIfChanged(oldValue, shellIntegration, key: "shell-integration") } }
    @Published var quitAfterLastWindowClosed: Bool = false { didSet { saveIfChanged(oldValue, quitAfterLastWindowClosed, key: "quit-after-last-window-closed") } }
    // confirm-close-surface is an enum
    @Published var confirmCloseSurface: String = "true" { didSet { saveIfChanged(oldValue, confirmCloseSurface, key: "confirm-close-surface") } }
    @Published var focusFollowsMouse: Bool = false { didSet { saveIfChanged(oldValue, focusFollowsMouse, key: "focus-follows-mouse") } }

    // MARK: - Appearance Settings

    @Published var windowTheme: String = "auto" { didSet { saveIfChanged(oldValue, windowTheme, key: "window-theme") } }
    @Published var windowDecoration: String = "auto" { didSet { saveIfChanged(oldValue, windowDecoration, key: "window-decoration") } }
    // background-opacity is f64
    @Published var backgroundOpacity: Double = 1.0
    // minimum-contrast is f64
    @Published var minimumContrast: Double = 1.0
    // unfocused-split-opacity is f64
    @Published var unfocusedSplitOpacity: Double = 0.7
    @Published var resizeOverlay: String = "after-first" { didSet { saveIfChanged(oldValue, resizeOverlay, key: "resize-overlay") } }
    @Published var fontThicken: Bool = false { didSet { saveIfChanged(oldValue, fontThicken, key: "font-thicken") } }

    // MARK: - macOS Settings

    @Published var macosTitlebarStyle: String = "transparent" { didSet { saveIfChanged(oldValue, macosTitlebarStyle, key: "macos-titlebar-style") } }
    @Published var macosOptionAsAlt: String = "false" { didSet { saveIfChanged(oldValue, macosOptionAsAlt, key: "macos-option-as-alt") } }
    @Published var macosNonNativeFullscreen: String = "false" { didSet { saveIfChanged(oldValue, macosNonNativeFullscreen, key: "macos-non-native-fullscreen") } }
    @Published var macosWindowButtons: String = "visible" { didSet { saveIfChanged(oldValue, macosWindowButtons, key: "macos-window-buttons") } }
    @Published var macosTitlebarProxyIcon: String = "visible" { didSet { saveIfChanged(oldValue, macosTitlebarProxyIcon, key: "macos-titlebar-proxy-icon") } }
    @Published var macosIcon: String = "official" { didSet { saveIfChanged(oldValue, macosIcon, key: "macos-icon") } }
    @Published var macosAutoSecureInput: Bool = true { didSet { saveIfChanged(oldValue, macosAutoSecureInput, key: "macos-auto-secure-input") } }
    @Published var macosWindowShadow: Bool = true { didSet { saveIfChanged(oldValue, macosWindowShadow, key: "macos-window-shadow") } }
    @Published var quickTerminalPosition: String = "top" { didSet { saveIfChanged(oldValue, quickTerminalPosition, key: "quick-terminal-position") } }
    @Published var quickTerminalAnimationDuration: Double = 0.2
    @Published var quickTerminalAutoHide: Bool = true { didSet { saveIfChanged(oldValue, quickTerminalAutoHide, key: "quick-terminal-autohide") } }

    // MARK: - Advanced Settings

    @Published var autoUpdate: String = "check" { didSet { saveIfChanged(oldValue, autoUpdate, key: "auto-update") } }
    @Published var autoUpdateChannel: String = "stable" { didSet { saveIfChanged(oldValue, autoUpdateChannel, key: "auto-update-channel") } }
    @Published var windowSaveState: String = "default" { didSet { saveIfChanged(oldValue, windowSaveState, key: "window-save-state") } }

    // MARK: - Internal State

    private var isLoading = true
    private var cancellables = Set<AnyCancellable>()

    init(config: Ghostty.Config) {
        loadValues(from: config)
        setupDebouncedSaves()
        isLoading = false
    }

    // MARK: - Load Values

    private func loadValues(from config: Ghostty.Config) {
        // General - font-family read from config file since it's a RepeatableString
        fontFamily = readFromConfigFile(key: "font-family") ?? ""
        fontSize = configFloat(config, key: "font-size") ?? 13
        cursorStyle = configString(config, key: "cursor-style") ?? "block"
        cursorStyleBlink = configString(config, key: "cursor-style-blink") ?? ""
        mouseHideWhileTyping = configBool(config, key: "mouse-hide-while-typing") ?? false
        copyOnSelect = configString(config, key: "copy-on-select") ?? "false"
        shellIntegration = configString(config, key: "shell-integration") ?? "detect"
        quitAfterLastWindowClosed = config.shouldQuitAfterLastWindowClosed
        confirmCloseSurface = configString(config, key: "confirm-close-surface") ?? "true"
        focusFollowsMouse = config.focusFollowsMouse

        // Appearance
        windowTheme = configString(config, key: "window-theme") ?? "auto"
        windowDecoration = configString(config, key: "window-decoration") ?? "auto"
        backgroundOpacity = config.backgroundOpacity
        minimumContrast = configDouble(config, key: "minimum-contrast") ?? 1.0
        unfocusedSplitOpacity = configDouble(config, key: "unfocused-split-opacity") ?? 0.7
        resizeOverlay = configString(config, key: "resize-overlay") ?? "after-first"
        fontThicken = configBool(config, key: "font-thicken") ?? false

        // macOS
        macosTitlebarStyle = configString(config, key: "macos-titlebar-style") ?? "transparent"
        macosOptionAsAlt = configString(config, key: "macos-option-as-alt") ?? "false"
        macosNonNativeFullscreen = configString(config, key: "macos-non-native-fullscreen") ?? "false"
        macosWindowButtons = configString(config, key: "macos-window-buttons") ?? "visible"
        macosTitlebarProxyIcon = configString(config, key: "macos-titlebar-proxy-icon") ?? "visible"
        macosIcon = configString(config, key: "macos-icon") ?? "official"
        macosAutoSecureInput = config.autoSecureInput
        macosWindowShadow = config.macosWindowShadow
        quickTerminalPosition = configString(config, key: "quick-terminal-position") ?? "top"
        quickTerminalAnimationDuration = config.quickTerminalAnimationDuration
        quickTerminalAutoHide = config.quickTerminalAutoHide

        // Advanced
        if let au = config.autoUpdate {
            autoUpdate = au.rawValue
        }
        autoUpdateChannel = config.autoUpdateChannel.rawValue
        windowSaveState = config.windowSaveState.isEmpty ? "default" : config.windowSaveState
    }

    // MARK: - Debounced Saves (for sliders)

    private func setupDebouncedSaves() {
        $backgroundOpacity
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.saveValue(String(value), key: "background-opacity")
            }
            .store(in: &cancellables)

        $minimumContrast
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.saveValue(String(value), key: "minimum-contrast")
            }
            .store(in: &cancellables)

        $unfocusedSplitOpacity
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.saveValue(String(value), key: "unfocused-split-opacity")
            }
            .store(in: &cancellables)

        $quickTerminalAnimationDuration
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.saveValue(String(format: "%.2f", value), key: "quick-terminal-animation-duration")
            }
            .store(in: &cancellables)
    }

    // MARK: - Save Helpers

    private func saveIfChanged<T: Equatable>(_ oldValue: T, _ newValue: T, key: String) {
        guard !isLoading, oldValue != newValue else { return }
        let stringValue: String
        if let boolValue = newValue as? Bool {
            stringValue = boolValue ? "true" : "false"
        } else if let uintValue = newValue as? UInt {
            stringValue = String(uintValue)
        } else if let doubleValue = newValue as? Double {
            stringValue = String(doubleValue)
        } else {
            stringValue = String(describing: newValue)
        }
        saveValue(stringValue, key: key)
    }

    private func saveValue(_ value: String, key: String) {
        guard ConfigFileEditor.applyChanges([key: value]) else { return }
        triggerReload()
    }

    private func triggerReload() {
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        delegate.reloadConfig(nil)
    }

    // MARK: - Config Reading Helpers

    /// Read a value directly from the config file (for types not accessible via C API)
    private func readFromConfigFile(key: String) -> String? {
        guard let path = ConfigFileEditor.configFilePath() else { return nil }
        guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
        let lines = ConfigFileEditor.parse(contents: contents)
        // Return the last occurrence of the key
        var result: String?
        for line in lines {
            if case .setting(let k, let v, _) = line, k == key {
                result = v
            }
        }
        return result
    }

    private func configString(_ config: Ghostty.Config, key: String) -> String? {
        guard let cfg = config.config else { return nil }
        var v: UnsafePointer<Int8>?
        guard ghostty_config_get(cfg, &v, key, UInt(key.lengthOfBytes(using: .utf8))) else { return nil }
        guard let ptr = v else { return nil }
        return String(cString: ptr)
    }

    private func configBool(_ config: Ghostty.Config, key: String) -> Bool? {
        guard let cfg = config.config else { return nil }
        var v = false
        guard ghostty_config_get(cfg, &v, key, UInt(key.lengthOfBytes(using: .utf8))) else { return nil }
        return v
    }

    private func configFloat(_ config: Ghostty.Config, key: String) -> Double? {
        guard let cfg = config.config else { return nil }
        var v: Float = 0
        guard ghostty_config_get(cfg, &v, key, UInt(key.lengthOfBytes(using: .utf8))) else { return nil }
        return Double(v)
    }

    private func configDouble(_ config: Ghostty.Config, key: String) -> Double? {
        guard let cfg = config.config else { return nil }
        var v: Double = 0
        guard ghostty_config_get(cfg, &v, key, UInt(key.lengthOfBytes(using: .utf8))) else { return nil }
        return v
    }
}
