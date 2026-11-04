import SwiftUI

struct BudgetView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var overallText = ""
    @State private var categoryTexts: [UUID: String] = [:]
    @State private var didSave = false

    private var budget: MonthlyBudget {
        store.budget(for: store.selectedMonth)
    }

    private var spendingCategories: [ExpenseCategory] {
        store.categories.filter { $0.name != "Income" }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    MonthPickerHeader(
                        month: $store.selectedMonth,
                        onPrevious: { store.shiftMonth(by: -1); reloadFields() },
                        onNext: { store.shiftMonth(by: 1); reloadFields() }
                    )

                    summaryCard

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Monthly Limit")
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                            .foregroundStyle(Theme.ink)

                        HStack {
                            Text("$")
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundStyle(Theme.muted)
                            TextField("0", text: $overallText)
                                .keyboardType(.decimalPad)
                                .font(.system(.title, design: .rounded).weight(.bold))
                                .foregroundStyle(Theme.ink)
                        }
                        .padding(16)
                        .background(Theme.accentSoft.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(18)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Theme.cardShadow, radius: 10, y: 4)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Category Budgets")
                            .font(.system(.headline, design: .rounded).weight(.semibold))
                            .foregroundStyle(Theme.ink)

                        Text("Optional caps help the health score and keep spending focused.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Theme.muted)

                        ForEach(spendingCategories) { category in
                            categoryBudgetRow(category)
                        }
                    }
                    .padding(18)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Theme.cardShadow, radius: 10, y: 4)

                    Button(action: save) {
                        Text(didSave ? "Saved" : "Save Budget")
                            .font(.system(.body, design: .rounded).weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(didSave ? Theme.accent.opacity(0.7) : Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Budget")
            .onAppear(perform: reloadFields)
            .onChange(of: store.selectedMonth) { _, _ in
                reloadFields()
            }
        }
    }

    private var summaryCard: some View {
        let spent = store.monthlySpending(for: store.selectedMonth)
        let limit = Double(overallText) ?? budget.overallLimit
        return BudgetProgressBar(spent: spent, limit: max(limit, 0.01))
    }

    private func categoryBudgetRow(_ category: ExpenseCategory) -> some View {
        let spent = store.spendingByCategory(for: store.selectedMonth)
            .first { $0.category.id == category.id }?.total ?? 0
        let limit = Double(categoryTexts[category.id] ?? "") ?? 0

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(category.color)
                    .frame(width: 24)
                Text(category.name)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text(Formatters.money(spent) + " spent")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Theme.muted)
            }

            HStack {
                TextField("Limit", text: binding(for: category.id))
                    .keyboardType(.decimalPad)
                    .font(.system(.body, design: .rounded))
                    .padding(10)
                    .background(Theme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                if limit > 0 {
                    Text(Formatters.pct(min(spent / limit, 9.99)))
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .foregroundStyle(spent > limit ? Theme.danger : Theme.accent)
                        .frame(width: 48, alignment: .trailing)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func binding(for id: UUID) -> Binding<String> {
        Binding(
            get: { categoryTexts[id] ?? "" },
            set: { categoryTexts[id] = $0 }
        )
    }

    private func reloadFields() {
        let current = store.budget(for: store.selectedMonth)
        overallText = String(format: "%.0f", current.overallLimit)
        var texts: [UUID: String] = [:]
        for category in spendingCategories {
            if let value = current.categoryLimits[category.id], value > 0 {
                texts[category.id] = String(format: "%.0f", value)
            } else {
                texts[category.id] = ""
            }
        }
        categoryTexts = texts
        didSave = false
    }

    private func save() {
        var updated = store.budget(for: store.selectedMonth)
        updated.overallLimit = Double(overallText) ?? updated.overallLimit
        var limits: [UUID: Double] = [:]
        for (id, text) in categoryTexts {
            if let value = Double(text), value > 0 {
                limits[id] = value
            }
        }
        updated.categoryLimits = limits
        store.updateBudget(updated)
        didSave = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            didSave = false
        }
    }
}
