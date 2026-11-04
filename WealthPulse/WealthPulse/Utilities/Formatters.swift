import Foundation

enum Formatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let compactMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()

    static func money(_ value: Double) -> String {
        currency.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }

    static func pct(_ value: Double) -> String {
        percent.string(from: NSNumber(value: value)) ?? String(format: "%.0f%%", value * 100)
    }
}
