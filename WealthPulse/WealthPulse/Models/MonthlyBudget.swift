import Foundation

struct MonthlyBudget: Identifiable, Codable, Hashable {
    var id: UUID
    var month: Int
    var year: Int
    var overallLimit: Double
    var categoryLimits: [UUID: Double]

    init(
        id: UUID = UUID(),
        month: Int,
        year: Int,
        overallLimit: Double = 3000,
        categoryLimits: [UUID: Double] = [:]
    ) {
        self.id = id
        self.month = month
        self.year = year
        self.overallLimit = overallLimit
        self.categoryLimits = categoryLimits
    }

    var periodKey: String {
        String(format: "%04d-%02d", year, month)
    }

    static func key(for date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
    }
}
