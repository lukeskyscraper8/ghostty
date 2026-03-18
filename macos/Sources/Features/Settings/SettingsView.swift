import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case appearance = "Appearance"
    case macos = "macOS"
    case advanced = "Advanced"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .appearance: return "paintbrush"
        case .macos: return "apple.logo"
        case .advanced: return "wrench.and.screwdriver"
        }
    }
}

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var selectedTab: SettingsTab = .general

    init(config: Ghostty.Config) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(config: config))
    }

    var body: some View {
        NavigationSplitView {
            List(SettingsTab.allCases, selection: $selectedTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 150, ideal: 180, max: 220)
        } detail: {
            ScrollView {
                detailView
                    .frame(maxWidth: 600)
            }
            .frame(maxWidth: .infinity)
            .navigationTitle(selectedTab.rawValue)
        }
        .frame(minWidth: 650, minHeight: 450)
        .frame(idealWidth: 750, idealHeight: 550)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedTab {
        case .general:
            GeneralSettingsView(viewModel: viewModel)
        case .appearance:
            AppearanceSettingsView(viewModel: viewModel)
        case .macos:
            MacOSSettingsView(viewModel: viewModel)
        case .advanced:
            AdvancedSettingsView(viewModel: viewModel)
        }
    }
}
