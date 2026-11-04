import SwiftUI

struct BudgetProgressBar: View {
    let spent: Double
    let limit: Double

    private var progress: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1.2)
    }

    private var barColor: Color {
        let ratio = limit > 0 ? spent / limit : 0
        if ratio > 1 { return Theme.danger }
        if ratio > 0.85 { return Theme.warning }
        return Theme.accent
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Budget vs Actual")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text("\(Formatters.money(spent)) / \(Formatters.money(limit))")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Theme.muted)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.chartTrack)
                    Capsule()
                        .fill(barColor)
                        .frame(width: max(8, geo.size.width * min(progress, 1)))
                        .animation(.easeOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 12)

            HStack {
                Text(remainingLabel)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(barColor)
                Spacer()
                Text(Formatters.pct(limit > 0 ? min(spent / limit, 9.99) : 0) + " used")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(18)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, y: 4)
    }

    private var remainingLabel: String {
        let remaining = limit - spent
        if remaining >= 0 {
            return "\(Formatters.money(remaining)) left"
        }
        return "\(Formatters.money(abs(remaining))) over"
    }
}
