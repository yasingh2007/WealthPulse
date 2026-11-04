import SwiftUI

struct MonthPickerHeader: View {
    @Binding var month: Date
    var onPrevious: () -> Void
    var onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 36, height: 36)
                    .background(Theme.surface)
                    .clipShape(Circle())
            }

            Spacer()

            Text(Formatters.monthYear.string(from: month))
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(Theme.ink)

            Spacer()

            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 36, height: 36)
                    .background(Theme.surface)
                    .clipShape(Circle())
            }
        }
    }
}
