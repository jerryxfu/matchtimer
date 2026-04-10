//
//  FloatingHeaderView.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-07.
//

import ComposeApp
import SwiftUI

struct ScheduleHeaderView: View {

    var body: some View {
        VStack(spacing: 12) {
            Text("Hello")
                .font(.title)

            Text("World")
                .font(.caption)
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
