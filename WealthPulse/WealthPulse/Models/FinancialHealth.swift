import Foundation
import SwiftUI

struct FinancialHealth {
    let score: Int
    let budgetAdherence: Double
    let savingsRate: Double
    let spendingStability: Double
    let netWorthTrend: Double

    var grade: String {
        switch score {
        case 85...100: return "Excellent"
        case 70..<85: return "Good"
        case 55..<70: return "Fair"
        case 40..<55: return "Needs Work"
        default: return "At Risk"
        }
    }

    var color: Color {
        switch score {
        case 85...100: return Color(hex: "06D6A0")
        case 70..<85: return Color(hex: "4ECDC4")
        case 55..<70: return Color(hex: "F2CC8F")
        case 40..<55: return Color(hex: "E07A5F")
        default: return Color(hex: "EF476F")
        }
    }

    var tips: [String] {
        var items: [String] = []
        if budgetAdherence < 0.8 {
            items.append("Stay under your monthly budget to raise your score.")
        }
        if savingsRate < 0.2 {
            items.append("Aim to save at least 20% of income each month.")
        }
        if spendingStability < 0.6 {
            items.append("Smooth out uneven spending across categories.")
        }
        if netWorthTrend < 0.5 {
            items.append("Grow assets or reduce liabilities to improve net worth.")
        }
        if items.isEmpty {
            items.append("You're on track — keep logging expenses consistently.")
        }
        return items
    }
}
