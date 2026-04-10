//
//  AlliancePickerView.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-07.
//

import ComposeApp
import SwiftUI

struct AlliancePickerView: View {
    let selectedAlliance: Alliance?
    let onAllianceSelected: (Alliance) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Which alliance scored lower in auto?")
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary)

            HStack(spacing: 8) {
                allianceButton(.red, label: "Red alliance")
                allianceButton(.blue, label: "Blue alliance")
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
    }

    private func allianceButton(_ alliance: Alliance, label: String)
        -> some View
    {
        let isSelected = selectedAlliance == alliance
        let color: Color = alliance == .red ? .red : .blue

        return Button(label) {
            onAllianceSelected(alliance)
        }
        .font(.system(size: 13, weight: .medium))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(isSelected ? color.opacity(0.1) : Color(.systemGray6))
        .foregroundStyle(isSelected ? color : Color.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? color : Color.clear, lineWidth: 1.5)
        )
    }
}
