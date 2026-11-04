import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case expense
    case income

    var id: String { rawValue }

    var label: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        }
    }
}

struct Expense: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var amount: Double
    var categoryId: UUID
    var date: Date
    var note: String
    var type: TransactionType

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        categoryId: UUID,
        date: Date = Date(),
        note: String = "",
        type: TransactionType = .expense
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.categoryId = categoryId
        self.date = date
        self.note = note
        self.type = type
    }

    var signedAmount: Double {
        type == .income ? amount : -amount
    }
}
