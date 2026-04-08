//
//  FloatingHeaderView.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-07.
//

import SwiftUI
import ComposeApp

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
                Button("Start", action: onStart)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("Stop", action: onStop)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
