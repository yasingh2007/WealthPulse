import Foundation
import SwiftUI
import Combine

@MainActor
final class FinanceStore: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var categories: [ExpenseCategory] = ExpenseCategory.defaults
    @Published var budgets: [MonthlyBudget] = []
    @Published var netWorthEntries: [NetWorthEntry] = []
    @Published var selectedMonth: Date = Date()

    private let expensesKey = "wp_expenses"
    private let categoriesKey = "wp_categories"
    private let budgetsKey = "wp_budgets"
    private let netWorthKey = "wp_networth"
    private let seededKey = "wp_seeded"

    init() {
        load()
        if !UserDefaults.standard.bool(forKey: seededKey) {
            seedSampleData()
            UserDefaults.standard.set(true, forKey: seededKey)
        }
    }

    // MARK: - Persistence

    private func load() {
        expenses = decode([Expense].self, key: expensesKey) ?? []
        categories = decode([ExpenseCategory].self, key: categoriesKey) ?? ExpenseCategory.defaults
        budgets = decode([MonthlyBudget].self, key: budgetsKey) ?? []
        netWorthEntries = decode([NetWorthEntry].self, key: netWorthKey) ?? []
    }

    private func save() {
        encode(expenses, key: expensesKey)
        encode(categories, key: categoriesKey)
        encode(budgets, key: budgetsKey)
        encode(netWorthEntries, key: netWorthKey)
    }

    private func encode<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    // MARK: - Expenses

    func addExpense(_ expense: Expense) {
        expenses.insert(expense, at: 0)
        save()
    }

    func updateExpense(_ expense: Expense) {
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        expenses[index] = expense
        save()
    }

    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        save()
    }

    func deleteExpenses(at offsets: IndexSet, from list: [Expense]) {
        let ids = offsets.map { list[$0].id }
        expenses.removeAll { ids.contains($0.id) }
        save()
    }

    // MARK: - Categories

    func addCategory(_ category: ExpenseCategory) {
        categories.append(category)
        save()
    }

    func updateCategory(_ category: ExpenseCategory) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[index] = category
        save()
    }

    func deleteCategory(_ category: ExpenseCategory) {
        guard !category.isDefault else { return }
        categories.removeAll { $0.id == category.id }
        if let fallback = categories.first {
            for i in expenses.indices where expenses[i].categoryId == category.id {
                expenses[i].categoryId = fallback.id
            }
        }
        save()
    }

    func category(for id: UUID) -> ExpenseCategory? {
        categories.first { $0.id == id }
    }

    // MARK: - Budgets

    func budget(for date: Date) -> MonthlyBudget {
        let key = MonthlyBudget.key(for: date)
        if let existing = budgets.first(where: { $0.periodKey == key }) {
            return existing
        }
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        let created = MonthlyBudget(
            month: comps.month ?? 1,
            year: comps.year ?? 2026,
            overallLimit: 3000
        )
        budgets.append(created)
        save()
        return created
    }

    func updateBudget(_ budget: MonthlyBudget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
        } else if let index = budgets.firstIndex(where: { $0.periodKey == budget.periodKey }) {
            budgets[index] = budget
        } else {
            budgets.append(budget)
        }
        save()
    }

    // MARK: - Net Worth

    func addNetWorth(_ entry: NetWorthEntry) {
        netWorthEntries.append(entry)
        netWorthEntries.sort { $0.date < $1.date }
        save()
    }

    func updateNetWorth(_ entry: NetWorthEntry) {
        guard let index = netWorthEntries.firstIndex(where: { $0.id == entry.id }) else { return }
        netWorthEntries[index] = entry
        netWorthEntries.sort { $0.date < $1.date }
        save()
    }

    func deleteNetWorth(_ entry: NetWorthEntry) {
        netWorthEntries.removeAll { $0.id == entry.id }
        save()
    }

    // MARK: - Queries

    var selectedMonthExpenses: [Expense] {
        expensesInMonth(selectedMonth)
    }

    func expensesInMonth(_ date: Date) -> [Expense] {
        let cal = Calendar.current
        return expenses.filter {
            cal.isDate($0.date, equalTo: date, toGranularity: .month)
        }
        .sorted { $0.date > $1.date }
    }

    func monthlySpending(for date: Date) -> Double {
        expensesInMonth(date)
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    func monthlyIncome(for date: Date) -> Double {
        expensesInMonth(date)
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    func savingsRate(for date: Date) -> Double {
        let income = monthlyIncome(for: date)
        guard income > 0 else { return 0 }
        let spending = monthlySpending(for: date)
        return max(0, (income - spending) / income)
    }

    func spendingByCategory(for date: Date) -> [(category: ExpenseCategory, total: Double)] {
        let monthExpenses = expensesInMonth(date).filter { $0.type == .expense }
        var totals: [UUID: Double] = [:]
        for expense in monthExpenses {
            totals[expense.categoryId, default: 0] += expense.amount
        }
        return totals.compactMap { id, total in
            guard let category = category(for: id) else { return nil }
            return (category, total)
        }
        .sorted { $0.total > $1.total }
    }

    func budgetProgress(for date: Date) -> Double {
        let budget = budget(for: date)
        guard budget.overallLimit > 0 else { return 0 }
        return monthlySpending(for: date) / budget.overallLimit
    }

    func financialHealth(for date: Date) -> FinancialHealth {
        let budget = budget(for: date)
        let spending = monthlySpending(for: date)
        let income = monthlyIncome(for: date)
        let savings = savingsRate(for: date)

        let adherence: Double
        if budget.overallLimit <= 0 {
            adherence = 0.5
        } else {
            let ratio = spending / budget.overallLimit
            adherence = ratio <= 1 ? 1.0 : max(0, 1 - (ratio - 1))
        }

        let savingsScore = min(1, savings / 0.3)

        let byCategory = spendingByCategory(for: date)
        let categoryCount = max(1, byCategory.count)
        let idealShare = 1.0 / Double(categoryCount)
        let variance: Double
        if spending > 0 && !byCategory.isEmpty {
            let sumSquares = byCategory.reduce(0.0) { partial, item in
                let share = item.total / spending
                return partial + pow(share - idealShare, 2)
            }
            variance = sumSquares / Double(byCategory.count)
        } else {
            variance = 0.25
        }
        let stability = max(0, 1 - min(1, variance * 8))

        let trendScore: Double
        if netWorthEntries.count >= 2 {
            let recent = Array(netWorthEntries.suffix(6))
            let first = recent.first!.netWorth
            let last = recent.last!.netWorth
            if first <= 0 {
                trendScore = last > 0 ? 1 : 0.4
            } else {
                let growth = (last - first) / abs(first)
                trendScore = min(1, max(0, 0.5 + growth))
            }
        } else if let only = netWorthEntries.last {
            trendScore = only.netWorth > 0 ? 0.6 : 0.3
        } else {
            trendScore = income > spending ? 0.55 : 0.35
        }

        let raw = (adherence * 0.35) + (savingsScore * 0.30) + (stability * 0.15) + (trendScore * 0.20)
        let score = Int((raw * 100).rounded())

        return FinancialHealth(
            score: min(100, max(0, score)),
            budgetAdherence: adherence,
            savingsRate: savings,
            spendingStability: stability,
            netWorthTrend: trendScore
        )
    }

    func shiftMonth(by value: Int) {
        if let next = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = next
        }
    }

    // MARK: - Seed

    private func seedSampleData() {
        let cal = Calendar.current
        let now = Date()
        guard let food = categories.first(where: { $0.name == "Food & Dining" }),
              let transport = categories.first(where: { $0.name == "Transport" }),
              let housing = categories.first(where: { $0.name == "Housing" }),
              let utilities = categories.first(where: { $0.name == "Utilities" }),
              let shopping = categories.first(where: { $0.name == "Shopping" }),
              let entertainment = categories.first(where: { $0.name == "Entertainment" }),
              let incomeCat = categories.first(where: { $0.name == "Income" }) else { return }

        func day(_ offset: Int) -> Date {
            cal.date(byAdding: .day, value: offset, to: now) ?? now
        }

        expenses = [
            Expense(title: "Salary", amount: 5200, categoryId: incomeCat.id, date: day(-2), type: .income),
            Expense(title: "Rent", amount: 1650, categoryId: housing.id, date: day(-1)),
            Expense(title: "Groceries", amount: 118.42, categoryId: food.id, date: day(0)),
            Expense(title: "Coffee", amount: 5.75, categoryId: food.id, date: day(0)),
            Expense(title: "Gas", amount: 48.20, categoryId: transport.id, date: day(-3)),
            Expense(title: "Electric Bill", amount: 96.10, categoryId: utilities.id, date: day(-5)),
            Expense(title: "Streaming", amount: 15.99, categoryId: entertainment.id, date: day(-6)),
            Expense(title: "New headphones", amount: 89.00, categoryId: shopping.id, date: day(-8)),
            Expense(title: "Dinner out", amount: 64.50, categoryId: food.id, date: day(-10)),
            Expense(title: "Transit pass", amount: 72.00, categoryId: transport.id, date: day(-12))
        ]

        let comps = cal.dateComponents([.year, .month], from: now)
        budgets = [
            MonthlyBudget(
                month: comps.month ?? 1,
                year: comps.year ?? 2026,
                overallLimit: 3200,
                categoryLimits: [
                    food.id: 450,
                    transport.id: 250,
                    housing.id: 1700,
                    utilities.id: 180,
                    entertainment.id: 120,
                    shopping.id: 200
                ]
            )
        ]

        netWorthEntries = [
            NetWorthEntry(date: cal.date(byAdding: .month, value: -5, to: now) ?? now, assets: 42000, liabilities: 18500),
            NetWorthEntry(date: cal.date(byAdding: .month, value: -4, to: now) ?? now, assets: 43500, liabilities: 18200),
            NetWorthEntry(date: cal.date(byAdding: .month, value: -3, to: now) ?? now, assets: 44800, liabilities: 17900),
            NetWorthEntry(date: cal.date(byAdding: .month, value: -2, to: now) ?? now, assets: 46100, liabilities: 17600),
            NetWorthEntry(date: cal.date(byAdding: .month, value: -1, to: now) ?? now, assets: 47800, liabilities: 17300),
            NetWorthEntry(date: now, assets: 49200, liabilities: 17000)
        ]

        save()
    }
}
