import SwiftUI

struct ExpensesListView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var showEditor = false
    @State private var editingExpense: Expense?
    @State private var filter: TransactionType? = nil
    @State private var searchText = ""

    private var filtered: [Expense] {
        store.selectedMonthExpenses.filter { expense in
            let matchesType = filter == nil || expense.type == filter
            let matchesSearch = searchText.isEmpty
                || expense.title.localizedCaseInsensitiveContains(searchText)
                || (store.category(for: expense.categoryId)?.name
                    .localizedCaseInsensitiveContains(searchText) ?? false)
            return matchesType && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MonthPickerHeader(
                    month: $store.selectedMonth,
                    onPrevious: { store.shiftMonth(by: -1) },
                    onNext: { store.shiftMonth(by: 1) }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)

                filterChips
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                List {
                    if filtered.isEmpty {
                        ContentUnavailableView(
                            "No transactions",
                            systemImage: "tray",
                            description: Text("Add an expense or income for this month.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(filtered) { expense in
                            Button {
                                editingExpense = expense
                            } label: {
                                ExpenseRowView(expense: expense)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Theme.surface)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.deleteExpense(expense)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Expenses")
            .searchable(text: $searchText, prompt: "Search expenses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingExpense = nil
                        showEditor = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                ExpenseEditorView()
            }
            .sheet(item: $editingExpense) { expense in
                ExpenseEditorView(expense: expense)
            }
        }
    }

    private var filterChips: some View {
        HStack(spacing: 8) {
            chip("All", selected: filter == nil) { filter = nil }
            chip("Expenses", selected: filter == .expense) { filter = .expense }
            chip("Income", selected: filter == .income) { filter = .income }
            Spacer()
        }
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(selected ? .white : Theme.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selected ? Theme.accent : Theme.surface)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
