import SwiftUI

struct HealthScoreRing: View {
    let score: Int
    let grade: String
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.chartTrack, lineWidth: 14)

            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: score)

            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text(grade)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(color)
            }
        }
        .frame(width: 150, height: 150)
    }
}
