import Foundation
import SwiftUI

struct ExpenseCategory: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isDefault: Bool

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isDefault = isDefault
    }

    var color: Color {
        Color(hex: colorHex)
    }

    static let defaults: [ExpenseCategory] = [
        ExpenseCategory(name: "Food & Dining", icon: "fork.knife", colorHex: "E07A5F", isDefault: true),
        ExpenseCategory(name: "Transport", icon: "car.fill", colorHex: "3D5A80", isDefault: true),
        ExpenseCategory(name: "Housing", icon: "house.fill", colorHex: "81B29A", isDefault: true),
        ExpenseCategory(name: "Utilities", icon: "bolt.fill", colorHex: "F2CC8F", isDefault: true),
        ExpenseCategory(name: "Shopping", icon: "bag.fill", colorHex: "D62828", isDefault: true),
        ExpenseCategory(name: "Entertainment", icon: "film.fill", colorHex: "457B9D", isDefault: true),
        ExpenseCategory(name: "Health", icon: "heart.fill", colorHex: "EF476F", isDefault: true),
        ExpenseCategory(name: "Income", icon: "banknote.fill", colorHex: "06D6A0", isDefault: true),
        ExpenseCategory(name: "Other", icon: "ellipsis.circle.fill", colorHex: "6C757D", isDefault: true)
    ]
}
