import ComposeApp
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MatchTimerViewModel()

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
