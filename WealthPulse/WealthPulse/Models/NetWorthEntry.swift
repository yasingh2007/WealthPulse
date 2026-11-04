import Foundation

struct NetWorthEntry: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var assets: Double
    var liabilities: Double
    var note: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        assets: Double,
        liabilities: Double = 0,
        note: String = ""
    ) {
        self.id = id
        self.date = date
        self.assets = assets
        self.liabilities = liabilities
        self.note = note
    }

    var netWorth: Double {
        assets - liabilities
    }
}
