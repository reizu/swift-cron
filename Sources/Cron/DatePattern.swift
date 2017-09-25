import Foundation

// maybe match/validate can come from next? match: next == current
// calendar.date(matching: datePattern, after: now)

// TODO: use failable init instead of throwing!

struct DCPattern {
    public enum Constraint {
        case at
        case every
    }

    public let constraint: Constraint
    public let value: Int

    public init(constraint: Constraint = .at, value: Int) {
        self.constraint = constraint
        self.value = value
    }
}

enum DatePatternError: Error {
    case invalidExpressionFormat
}

func parse(component: String) throws -> DCPattern? {
    if component == "*" {
        return nil
    } else if let value = Int(component) {
        return DCPattern(constraint: .at, value: value)
    } else if component.hasPrefix("*/") {
        let components = component.split(separator: "/")
        if let value = Int(components[1]) {
            return DCPattern(constraint: .every, value: value)
        }
    }

    throw DatePatternError.invalidExpressionFormat
}

public struct DatePattern {
    let minutePattern: DCPattern?
    let hourPattern: DCPattern?

    public init?(_ expression: String) {
        let expressionComponents = expression.split(separator: " ")

        do {
            minutePattern = try parse(component: String(expressionComponents[0]))
            hourPattern = try parse(component: String(expressionComponents[1]))
        } catch {
            return nil
        }
    }

    public func isMatching(with date: Date) -> Bool {
        // TODO: implement me
        // TODO: needs a better name!
        return false
    }

    public func date(after startDate: Date) -> Date? {
        let calendar = Calendar.current

        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .weekday],
            from: startDate
        )

        if let minutePattern = minutePattern {
            var value: Int

            switch minutePattern.constraint {
            case .at:
                value = minutePattern.value

            case .every:
                value = ((components.minute! / minutePattern.value) * minutePattern.value) + minutePattern.value
            }

            if value < components.minute! {
                components.hour! += 1
            }

            components.minute = value
        }

        if let hourPattern = hourPattern {
            var value: Int

            switch hourPattern.constraint {
            case .at:
                value = hourPattern.value

            case .every:
                value = ((components.hour! / hourPattern.value) * hourPattern.value) + hourPattern.value
            }

            if value < components.hour! {
                components.hour! += 1
            }
            
            components.hour = value
        }

        return calendar.date(from: components)
    }
}
