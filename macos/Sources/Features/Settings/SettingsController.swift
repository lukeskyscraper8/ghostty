import Foundation
import Cocoa
import SwiftUI

class SettingsController: NSWindowController, NSWindowDelegate {
    static let shared: SettingsController = SettingsController()

    override var windowNibName: NSNib.Name? { "Settings" }

    /// The config to use for reading current values. Set before showing.
    var config: Ghostty.Config?

    override func windowDidLoad() {
        guard let window = window else { return }
        window.center()

        guard let config = self.config else { return }
        let settingsView = SettingsView(config: config)
        window.contentView = NSHostingView(rootView: settingsView)
    }

    // MARK: - Functions

    func show(config: Ghostty.Config) {
        self.config = config

        if let window = window {
            // If the window is already loaded, update the content view
            let settingsView = SettingsView(config: config)
            window.contentView = NSHostingView(rootView: settingsView)
            window.makeKeyAndOrderFront(nil)
        } else {
            // First time - load the window
            showWindow(nil)
        }
    }

    func hide() {
        window?.close()
    }

    // MARK: - First Responder

    @IBAction func close(_ sender: Any) {
        self.window?.performClose(sender)
    }

    @IBAction func closeWindow(_ sender: Any) {
        self.window?.performClose(sender)
    }

    @objc func cancel(_ sender: Any?) {
        close()
    }
}
