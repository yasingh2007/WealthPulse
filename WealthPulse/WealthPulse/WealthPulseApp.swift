import SwiftUI

@main
struct WealthPulseApp: App {
    @StateObject private var store = FinanceStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}
