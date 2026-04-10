//
//  FloatingHeaderView.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-07.
//

import ComposeApp
import SwiftUI

struct FloatingHeaderView: View {
    let matchState: MatchState
    let onStart: () -> Void
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(timeString(from: matchState.totalSecondsRemaining))
                .font(.system(size: 56, weight: .semibold, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 12) {
                if #available(iOS 26.0, *) {
                    Button("Start", action: onStart)
                        .buttonSizing(.flexible)
                        .font(.title2)
                        .tint(.green)
                        .buttonStyle(.glass)
                } else {
                    Button("Start", action: onStart)
                }

                if #available(iOS 26.0, *) {
                    Button("Stop", action: onStop)
                        .buttonSizing(.flexible)
                        .font(.title2)
                        .tint(.red)
                        .buttonStyle(.glass)
                } else {
                    Button("Start", action: onStart)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 60)
        .padding(.bottom, 16)
    }

    private func timeString(from seconds: Int32) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
