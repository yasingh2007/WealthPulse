import SwiftUI
import Charts

struct NetWorthTrendChart: View {
    let entries: [NetWorthEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Net Worth Trend")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                if let latest = entries.last {
                    Text(Formatters.money(latest.netWorth))
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(Theme.accent)
                }
            }

            if entries.count < 2 {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 32))
                        .foregroundStyle(Theme.muted.opacity(0.5))
                    Text("Add at least two snapshots to see a trend")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Theme.muted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
            } else {
                Chart(entries) { entry in
                    AreaMark(
                        x: .value("Date", entry.date),
                        y: .value("Net Worth", entry.netWorth)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.accent.opacity(0.35), Theme.accent.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Net Worth", entry.netWorth)
                    )
                    .foregroundStyle(Theme.accent)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("Net Worth", entry.netWorth)
                    )
                    .foregroundStyle(Theme.accent)
                    .symbolSize(36)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                        AxisValueLabel()
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Theme.muted)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                            .foregroundStyle(Theme.chartTrack)
                        AxisValueLabel {
                            if let number = value.as(Double.self) {
                                Text(compactMoney(number))
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundStyle(Theme.muted)
                            }
                        }
                    }
                }
                .frame(height: 180)
            }
        }
        .padding(18)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, y: 4)
    }

    private func compactMoney(_ value: Double) -> String {
        if abs(value) >= 1000 {
            return String(format: "$%.1fk", value / 1000)
        }
        return Formatters.money(value)
    }
}
