//
//  ScoutTabView.swift
//  iosApp
//
//  Created by Jerry Fu on 2026-04-11.
//

import SwiftUI

struct ScoutTabView: View {
    private let robot: RobotCheatSheet
    private let defaultRowUnits: [MetricField: UnitSystem]
    @State private var globalUnitSystem: UnitSystem?
    @State private var rowUnitOverrides: [MetricField: UnitSystem] = [:]

    init() {
        let robot = RobotCheatSheet.defaultRobot
        self.robot = robot
        self.defaultRowUnits = Self.makeDefaultRowUnits(from: robot)
        _globalUnitSystem = State(initialValue: nil)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HeaderCard(robot: robot)

                    UnitToggleRow(onApplyToAll: applyGlobalUnitSystem)

                    CheatSheetSection(title: "Core Specs") {
                        ForEach(
                            Array(robot.coreSpecRows.enumerated()),
                            id: \.element.id
                        ) { index, row in
                            coreSpecRow(
                                row,
                                showsDivider: index < robot.coreSpecRows.count
                                    - 1
                            )
                        }
                    }

                    CheatSheetSection(title: "Dimensions") {
                        ForEach(
                            Array(robot.dimensionRows.enumerated()),
                            id: \.element.id
                        ) { index, row in
                            unitSpecRow(
                                row,
                                showsDivider: index < robot.dimensionRows.count
                                    - 1
                            )
                        }
                    }

                    CheatSheetSection(title: "Capabilities") {
                        ForEach(
                            Array(robot.capabilities.enumerated()),
                            id: \.element.id
                        ) {
                            index,
                            capability in
                            CapabilityRow(
                                capability: capability,
                                showsDivider: index < robot.capabilities.count
                                    - 1
                            )
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Scout")
        }
    }

    private func toggleRowUnit(_ field: MetricField) {
        let next = effectiveUnitSystem(for: field).toggled
        let baseline = globalUnitSystem ?? defaultRowUnits[field] ?? .imperial
        if next == baseline {
            rowUnitOverrides.removeValue(forKey: field)
        } else {
            rowUnitOverrides[field] = next
        }
    }

    private func effectiveUnitSystem(for field: MetricField) -> UnitSystem {
        rowUnitOverrides[field] ?? globalUnitSystem ?? defaultRowUnits[field]
            ?? .imperial
    }

    private func applyGlobalUnitSystem(_ system: UnitSystem) {
        globalUnitSystem = system
        // Global buttons are explicit set-all actions, so clear row overrides.
        rowUnitOverrides.removeAll()
    }

    private static func makeDefaultRowUnits(
        from robot: RobotCheatSheet
    ) -> [MetricField: UnitSystem] {
        var defaults: [MetricField: UnitSystem] = [:]

        for row in robot.coreSpecRows {
            if case .unit(let unitRow) = row {
                defaults[unitRow.field] = unitSystem(for: unitRow.value)
            }
        }

        for row in robot.dimensionRows {
            defaults[row.field] = unitSystem(for: row.value)
        }

        return defaults
    }

    private static func unitSystem(for value: RobotCheatSheet.UnitValue)
        -> UnitSystem
    {
        switch value {
        case .mass(let mass):
            return isImperialMass(mass.unit.symbol) ? .imperial : .metric
        case .length(let length):
            return isImperialLength(length.unit.symbol) ? .imperial : .metric
        case .speed(let speed):
            return isImperialSpeed(speed.unit.symbol) ? .imperial : .metric
        }
    }

    private static func isImperialMass(_ symbol: String) -> Bool {
        let normalized = symbol.lowercased()
        return normalized == "lb" || normalized == "lbs" || normalized == "oz"
    }

    private static func isImperialLength(_ symbol: String) -> Bool {
        let normalized = symbol.lowercased()
        return normalized == "in" || normalized == "ft" || normalized == "yd"
            || normalized == "mi"
    }

    private static func isImperialSpeed(_ symbol: String) -> Bool {
        let normalized = symbol.lowercased()
        return normalized.contains("ft/s") || normalized == "mph"
    }

    @ViewBuilder
    private func coreSpecRow(
        _ row: RobotCheatSheet.CoreSpecRow,
        showsDivider: Bool
    ) -> some View {
        switch row {
        case .text(let textRow):
            TextMetricRow(
                label: textRow.label,
                value: textRow.value,
                showsDivider: showsDivider
            )
        case .unit(let unitRow):
            unitSpecRow(unitRow, showsDivider: showsDivider)
        }
    }

    private func unitSpecRow(
        _ row: RobotCheatSheet.UnitSpecRow,
        showsDivider: Bool
    ) -> some View {
        let formatted = formattedValue(row.value, for: row.field)
        return UnitMetricRow(
            label: row.label,
            value: formatted.value,
            unit: formatted.unit,
            onUnitTap: { toggleRowUnit(row.field) },
            showsDivider: showsDivider
        )
    }

    private func formattedValue(
        _ value: RobotCheatSheet.UnitValue,
        for field: MetricField
    ) -> (value: String, unit: String) {
        switch value {
        case .mass(let mass):
            return formattedMass(mass, for: field)
        case .length(let length):
            return formattedLength(length, for: field)
        case .speed(let speed):
            return formattedSpeed(speed, for: field)
        }
    }

    private func formattedMass(
        _ value: Measurement<UnitMass>,
        for field: MetricField
    ) -> (value: String, unit: String) {
        switch effectiveUnitSystem(for: field) {
        case .imperial:
            return (formatNumber(value.converted(to: .pounds).value), "lb")
        case .metric:
            return (formatNumber(value.converted(to: .kilograms).value), "kg")
        }
    }

    private func formattedLength(
        _ value: Measurement<UnitLength>,
        for field: MetricField
    ) -> (value: String, unit: String) {
        switch effectiveUnitSystem(for: field) {
        case .imperial:
            return (formatNumber(value.converted(to: .inches).value), "in")
        case .metric:
            return (formatNumber(value.converted(to: .centimeters).value), "cm")
        }
    }

    private func formattedSpeed(
        _ value: Measurement<UnitSpeed>,
        for field: MetricField
    ) -> (value: String, unit: String) {
        switch effectiveUnitSystem(for: field) {
        case .imperial:
            return (
                formatNumber(value.converted(to: .frcFeetPerSecond).value),
                "ft/s"
            )
        case .metric:
            return (
                formatNumber(value.converted(to: .metersPerSecond).value), "m/s"
            )
        }
    }

    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number))
            ?? String(format: "%.1f", number)
    }
}

private enum UnitSystem: String, CaseIterable, Identifiable {
    case imperial
    case metric

    var id: String { rawValue }

    var title: String {
        switch self {
        case .imperial: return "Imperial"
        case .metric: return "Metric"
        }
    }

    var toggled: UnitSystem {
        self == .imperial ? .metric : .imperial
    }
}

private enum MetricField: String, Hashable {
    case weight
    case topSpeed
    case length
    case width
    case height
    case framePerimeter
}

private struct RobotCheatSheet {
    enum UnitValue {
        case mass(Measurement<UnitMass>)
        case length(Measurement<UnitLength>)
        case speed(Measurement<UnitSpeed>)
    }

    struct UnitSpecRow: Identifiable {
        let id: String
        let label: String
        let field: MetricField
        let value: UnitValue
    }

    struct TextSpecRow: Identifiable {
        let id: String
        let label: String
        let value: String
    }

    enum CoreSpecRow: Identifiable {
        case unit(UnitSpecRow)
        case text(TextSpecRow)

        var id: String {
            switch self {
            case .unit(let row): return row.id
            case .text(let row): return row.id
            }
        }
    }

    struct Dimensions {
        let length: Measurement<UnitLength>
        let width: Measurement<UnitLength>
        let height: Measurement<UnitLength>
        let framePerimeter: Measurement<UnitLength>
    }

    struct Capability: Identifiable {
        let id = UUID()
        let name: String
        let details: String
    }

    let teamNumber: String
    let robotName: String
    let weight: Measurement<UnitMass>
    let drivebase: String
    let topSpeed: Measurement<UnitSpeed>
    let dimensions: Dimensions
    let capabilities: [Capability]

    var coreSpecRows: [CoreSpecRow] {
        [
            .unit(
                UnitSpecRow(
                    id: MetricField.weight.rawValue,
                    label: "Weight",
                    field: .weight,
                    value: .mass(weight)
                )
            ),
            .text(
                TextSpecRow(
                    id: "drivebase",
                    label: "Drivebase",
                    value: drivebase
                )
            ),
            .unit(
                UnitSpecRow(
                    id: MetricField.topSpeed.rawValue,
                    label: "Top Speed",
                    field: .topSpeed,
                    value: .speed(topSpeed)
                )
            ),
        ]
    }

    var dimensionRows: [UnitSpecRow] {
        [
            UnitSpecRow(
                id: MetricField.length.rawValue,
                label: "Length",
                field: .length,
                value: .length(dimensions.length)
            ),
            UnitSpecRow(
                id: MetricField.width.rawValue,
                label: "Width",
                field: .width,
                value: .length(dimensions.width)
            ),
            UnitSpecRow(
                id: MetricField.height.rawValue,
                label: "Height",
                field: .height,
                value: .length(dimensions.height)
            ),
            UnitSpecRow(
                id: MetricField.framePerimeter.rawValue,
                label: "Frame Perimeter",
                field: .framePerimeter,
                value: .length(dimensions.framePerimeter)
            ),
        ]
    }

    static let defaultRobot = RobotCheatSheet(
        teamNumber: "FRC 3990",
        robotName: "Atlas",
        weight: Measurement(value: 114.5, unit: .pounds),
        drivebase: "Swerve Mk5n R2",
        topSpeed: Measurement(value: 5.0, unit: .metersPerSecond),
        dimensions: Dimensions(
            length: Measurement(value: 27.5, unit: .inches),
            width: Measurement(value: 27.5, unit: .inches),
            height: Measurement(value: 21.75, unit: .inches),
            framePerimeter: Measurement(value: (27.5 * 4), unit: .inches)
        ),
        capabilities: [
            // low CG, climber is a circular hoo
            Capability(
                name: "Movement",
                details:
                    "TRENCH and BUMP (angled frame)"
            ),
            Capability(
                name: "Autonomous",
                details: "Pathplanner, Double swipe TRENCH -> BUMP"
            ),
            Capability(
                name: "Climb",
                details: "YES, L1 TELEOP"
            ),
            Capability(
                name: "Shooter",
                details: "6 bps, Shoot on the move, TURRET and HOOD"
            ),
            Capability(
                name: "Spindexer",
                details: "Omniwheel cone"
            ),
            Capability(
                name: "Intake",
                details: "60 ball capacity, over the bumper"
            ),
            Capability(
                name: "Vision",
                details: "2x LL 3G, one LL 4"
            ),
            Capability(
                name: "Programming",
                details: "Java"
            ),
        ]
    )
}

private struct HeaderCard: View {
    let robot: RobotCheatSheet

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(robot.teamNumber)
                .font(.title2.bold())
            Text(robot.robotName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Quick reference for pit and stands conversations.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct CheatSheetSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            VStack(spacing: 0) {
                content
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

private struct UnitToggleRow: View {
    let onApplyToAll: (UnitSystem) -> Void

    var body: some View {
        HStack(spacing: 8) {
            unitButton(.imperial)
            unitButton(.metric)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func unitButton(_ system: UnitSystem) -> some View {
        return Group {
            if #available(iOS 26.0, *) {
                Button(system.title) {
                    onApplyToAll(system)
                }
                .buttonSizing(.flexible)
                .font(.system(size: 13, weight: .semibold))
                .tint(.gray)
                .buttonStyle(.glass)
            } else {
                Button(system.title) {
                    onApplyToAll(system)
                }
                .font(.system(size: 13, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(.tertiarySystemFill))
                .foregroundStyle(Color.secondary)
                .clipShape(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
            }
        }
    }
}

private struct TextMetricRow: View {
    let label: String
    let value: String
    let showsDivider: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(value)
                    .multilineTextAlignment(.trailing)
            }
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)

            if showsDivider {
                Divider()
                    .padding(.leading, 14)
            }
        }
    }
}

private struct UnitMetricRow: View {
    let label: String
    let value: String
    let unit: String
    let onUnitTap: () -> Void
    let showsDivider: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 6) {
                    Text(value)
                        .fontWeight(.semibold)
                    Group {
                        if #available(iOS 26.0, *) {
                            Button(action: onUnitTap) {
                                Text(unit)
                                    .font(.footnote)
                            }
                            .tint(.secondary)
                            .buttonStyle(.glass)
                        } else {
                            Button(action: onUnitTap) {
                                Text(unit)
                                    .font(.footnote.weight(.semibold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Color(.tertiarySystemFill),
                                        in: Capsule()
                                    )
                                    .contentShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)

            if showsDivider {
                Divider()
                    .padding(.leading, 14)
            }
        }
    }
}

private struct CapabilityRow: View {
    let capability: RobotCheatSheet.Capability
    let showsDivider: Bool

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(capability.name)
                    .font(.subheadline.weight(.semibold))
                Text(capability.details)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)

            if showsDivider {
                Divider()
                    .padding(.leading, 14)
            }
        }
    }
}

extension UnitSpeed {
    // UnitSpeed does not include feet/second by default, so define it once for the scout sheet.
    fileprivate static let frcFeetPerSecond = UnitSpeed(
        symbol: "ft/s",
        converter: UnitConverterLinear(coefficient: 0.3048)
    )
}

#Preview {
    ScoutTabView()
}
