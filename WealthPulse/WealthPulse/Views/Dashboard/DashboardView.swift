import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var showQuickAdd = false

    private var health: FinancialHealth {
        store.financialHealth(for: store.selectedMonth)
    }

    private var spending: Double {
        store.monthlySpending(for: store.selectedMonth)
    }

    private var income: Double {
        store.monthlyIncome(for: store.selectedMonth)
    }

    private var budget: MonthlyBudget {
        store.budget(for: store.selectedMonth)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    MonthPickerHeader(
                        month: $store.selectedMonth,
                        onPrevious: { store.shiftMonth(by: -1) },
                        onNext: { store.shiftMonth(by: 1) }
                    )
                    .padding(.horizontal, 4)

                    heroBanner

                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 12
                    ) {
                        MetricCard(
                            title: "Monthly Spend",
                            value: Formatters.money(spending),
                            subtitle: income > 0 ? "of \(Formatters.money(income)) income" : "No income logged",
                            accent: Theme.danger,
                            icon: "arrow.down.circle.fill"
                        )
                        MetricCard(
                            title: "Savings Rate",
                            value: Formatters.pct(store.savingsRate(for: store.selectedMonth)),
                            subtitle: Formatters.money(max(0, income - spending)) + " saved",
                            accent: Theme.accent,
                            icon: "leaf.fill"
                        )
                    }

                    BudgetProgressBar(spent: spending, limit: budget.overallLimit)

                    CategoryPieChart(data: store.spendingByCategory(for: store.selectedMonth))

                    NetWorthTrendChart(entries: store.netWorthEntries)

                    healthDetailCard

                    recentExpenses
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "E8F2ED"), Theme.background],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("WealthPulse")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showQuickAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.accent)
                    }
                    .accessibilityLabel("Add expense")
                }
            }
            .sheet(isPresented: $showQuickAdd) {
                ExpenseEditorView()
            }
        }
    }

    private var heroBanner: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Financial Health")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text(health.grade)
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)

                Text("Based on budget, savings, spending mix, and net worth.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            HealthScoreRing(score: health.score, grade: health.grade, color: .white)
                .scaleEffect(0.85)
        }
        .padding(20)
        .background(Theme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.accent.opacity(0.35), radius: 16, y: 8)
    }

    private var healthDetailCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How to improve")
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(Theme.ink)

            ForEach(Array(health.tips.enumerated()), id: \.offset) { _, tip in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.accent)
                        .padding(.top, 2)
                    Text(tip)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Theme.muted)
                }
            }

            Divider().padding(.vertical, 4)

            HStack {
                scorePill("Budget", health.budgetAdherence)
                scorePill("Save", health.savingsRate == 0 && income == 0 ? 0 : min(1, health.savingsRate / 0.3))
                scorePill("Mix", health.spendingStability)
                scorePill("Worth", health.netWorthTrend)
            }
        }
        .padding(18)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, y: 4)
    }

    private func scorePill(_ title: String, _ value: Double) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(.caption2, design: .rounded).weight(.semibold))
                .foregroundStyle(Theme.muted)
            Text("\(Int((value * 100).rounded()))")
                .font(.system(.callout, design: .rounded).weight(.bold))
                .foregroundStyle(Theme.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Theme.accentSoft.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var recentExpenses: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text("\(store.selectedMonthExpenses.count) this month")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Theme.muted)
            }

            let preview = Array(store.selectedMonthExpenses.prefix(5))
            if preview.isEmpty {
                Text("No transactions yet — tap + to add one.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Theme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
            } else {
                ForEach(preview) { expense in
                    ExpenseRowView(expense: expense)
                }
            }
        }
        .padding(18)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, y: 4)
    }
}
