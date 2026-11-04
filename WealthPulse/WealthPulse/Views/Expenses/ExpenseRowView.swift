import SwiftUI

struct ExpenseRowView: View {
    @EnvironmentObject private var store: FinanceStore
    let expense: Expense

    private var category: ExpenseCategory? {
        store.category(for: expense.categoryId)
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill((category?.color ?? Theme.muted).opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: category?.icon ?? "tag.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(category?.color ?? Theme.muted)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Text("\(category?.name ?? "Uncategorized") · \(Formatters.shortDate.string(from: expense.date))")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Theme.muted)
            }

            Spacer()

            Text(amountLabel)
                .font(.system(.body, design: .rounded).weight(.bold))
                .foregroundStyle(expense.type == .income ? Theme.accent : Theme.ink)
        }
        .padding(.vertical, 4)
    }

    private var amountLabel: String {
        let prefix = expense.type == .income ? "+" : "-"
        return prefix + Formatters.money(expense.amount)
    }
}
