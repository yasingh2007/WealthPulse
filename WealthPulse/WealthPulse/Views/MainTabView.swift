import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)

            ExpensesListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(1)

            BudgetView()
                .tabItem {
                    Label("Budget", systemImage: "target")
                }
                .tag(2)

            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "tag.fill")
                }
                .tag(3)

            NetWorthView()
                .tabItem {
                    Label("Net Worth", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(4)
        }
        .tint(Theme.accent)
    }
}
