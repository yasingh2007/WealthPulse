import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var accent: Color = Theme.accent
    var icon: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(Theme.muted)
                    .textCase(.uppercase)
                    .tracking(0.6)
                Spacer()
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(accent)
                }
            }

            Text(value)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(Theme.ink)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            if let subtitle {
                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, y: 4)
    }
}
