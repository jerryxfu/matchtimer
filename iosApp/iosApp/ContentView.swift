import ComposeApp
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MatchTimerViewModel()

    var body: some View {
        if #available(iOS 26.0, *) {
            tabViewModern
        } else {
            tabViewLegacy
        }
    }

    @available(iOS 26.0, *)
    private var tabViewModern: some View {
        TabView {
            Tab("Schedule", systemImage: "calendar") {
                ScheduleView()
            }

            Tab("Match", systemImage: "timer") {
                MatchView(viewModel: viewModel)
            }

            Tab("Pit", systemImage: "hammer") {
                PlaceholderView(title: "Pit", icon: "hammer")
            }

            Tab("Settings", systemImage: "gear") {
                PlaceholderView(title: "Settings", icon: "gear")
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }

    private var tabViewLegacy: some View {
        TabView {
            MatchView(viewModel: viewModel)
                .tabItem {
                    Label("Match", systemImage: "timer")
                }

            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }

            PlaceholderView(title: "Stats", icon: "chart.bar")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }

            PlaceholderView(title: "Settings", icon: "gear")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// MARK: - Match tab

private struct MatchView: View {
    @ObservedObject var viewModel: MatchTimerViewModel

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 208)
                    PhaseListView(
                        matchState: viewModel.matchState,
                        selectedAlliance: viewModel.lowestAutoAlliance,
                        onAllianceSelected: { viewModel.setLowestAlliance($0) }
                    )
                }
            }

            FloatingHeaderView(
                matchState: viewModel.matchState,
                onStart: viewModel.start,
                onStop: viewModel.stop
            )
            .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Placeholder

private struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text("Coming soon")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
