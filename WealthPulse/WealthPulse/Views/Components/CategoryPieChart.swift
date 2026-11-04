import SwiftUI
import Charts

struct CategoryPieChart: View {
    let data: [(category: ExpenseCategory, total: Double)]

    private var grandTotal: Double {
        data.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending by Category")
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(Theme.ink)

            if data.isEmpty {
                emptyState
            } else {
                Chart(data, id: \.category.id) { item in
                    SectorMark(
                        angle: .value("Amount", item.total),
                        innerRadius: .ratio(0.58),
                        angularInset: 1.5
                    )
                    .foregroundStyle(item.category.color)
                    .cornerRadius(4)
                }
                .frame(height: 220)
                .chartBackground { _ in
                    VStack(spacing: 2) {
                        Text("Total")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Theme.muted)
                        Text(Formatters.money(grandTotal))
                            .font(.system(.callout, design: .rounded).weight(.bold))
                            .foregroundStyle(Theme.ink)
                    }
                }

                VStack(spacing: 10) {
                    ForEach(data, id: \.category.id) { item in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 10, height: 10)

                            Image(systemName: item.category.icon)
                                .font(.system(size: 12))
                                .foregroundStyle(item.category.color)
                                .frame(width: 18)

                            Text(item.category.name)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(Theme.ink)

                            Spacer()

                            Text(shareLabel(for: item.total))
                                .font(.system(.caption, design: .rounded).weight(.medium))
                                .foregroundStyle(Theme.muted)

                            Text(Formatters.money(item.total))
                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                .foregroundStyle(Theme.ink)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, y: 4)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie")
                .font(.system(size: 36))
                .foregroundStyle(Theme.muted.opacity(0.5))
            Text("No spending this month")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(Theme.muted)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
    }

    private func shareLabel(for amount: Double) -> String {
        guard grandTotal > 0 else { return "0%" }
        return Formatters.pct(amount / grandTotal)
    }
}
