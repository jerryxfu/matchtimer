import Foundation

struct RobotCheatSheet {
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
            Capability(
                name: "Movement",
                details: "TRENCH and BUMP (angled frame)"
            ),
            Capability(
                name: "Autonomous",
                details: "Pathplanner, Double swipe TRENCH -> BUMP"
            ),
            Capability(name: "Climb", details: "YES, L1 TELEOP"),
            Capability(
                name: "Shooter",
                details: "6 bps, Shoot on the move, TURRET and HOOD"
            ),
            Capability(name: "Spindexer", details: "Omniwheel cone"),
            Capability(
                name: "Intake",
                details: "60 ball capacity, over the bumper"
            ),
            Capability(name: "Vision", details: "2x LL 3G, one LL 4"),
            Capability(name: "Programming", details: "Java"),
        ]
    )
}

enum MetricField: String, Hashable {
    case weight, topSpeed, length, width, height, framePerimeter
}

enum UnitSystem: String, CaseIterable, Identifiable {
    case imperial, metric

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

extension UnitSpeed {
    static let frcFeetPerSecond = UnitSpeed(
        symbol: "ft/s",
        converter: UnitConverterLinear(coefficient: 0.3048)
    )
}
