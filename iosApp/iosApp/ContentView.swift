import SwiftUI
import ComposeApp

struct ContentView: View {
    @StateObject private var viewModel = MatchTimerViewModel()
    @State private var headerHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: headerHeight)
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
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        headerHeight = geo.size.height
                    }
                }
            )
        }
        .ignoresSafeArea(edges: .top)
    }
}
