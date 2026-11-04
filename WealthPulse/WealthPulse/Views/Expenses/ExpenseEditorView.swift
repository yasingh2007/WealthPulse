import SwiftUI

struct ExpenseEditorView: View {
    @EnvironmentObject private var store: FinanceStore
    @Environment(\.dismiss) private var dismiss

    var expense: Expense?

    @State private var title = ""
    @State private var amountText = ""
    @State private var categoryId: UUID?
    @State private var date = Date()
    @State private var note = ""
    @State private var type: TransactionType = .expense
    @State private var showDeleteConfirm = false

    private var isEditing: Bool { expense != nil }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && (Double(amountText) ?? 0) > 0
            && categoryId != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases) { item in
                            Text(item.label).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Title", text: $title)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)

                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    Picker("Category", selection: $categoryId) {
                        Text("Select").tag(UUID?.none)
                        ForEach(store.categories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(Optional(category.id))
                        }
                    }
                }

                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                if isEditing {
                    Section {
                        Button("Delete Transaction", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit" : "Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                        .fontWeight(.semibold)
                }
            }
            .onAppear(perform: hydrate)
            .confirmationDialog(
                "Delete this transaction?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let expense {
                        store.deleteExpense(expense)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func hydrate() {
        if let expense {
            title = expense.title
            amountText = String(format: "%.2f", expense.amount)
            categoryId = expense.categoryId
            date = expense.date
            note = expense.note
            type = expense.type
        } else {
            categoryId = store.categories.first?.id
            date = store.selectedMonth
            let comps = Calendar.current.dateComponents([.year, .month], from: store.selectedMonth)
            let todayComps = Calendar.current.dateComponents([.year, .month], from: Date())
            if comps.year == todayComps.year && comps.month == todayComps.month {
                date = Date()
            }
        }
    }

    private func save() {
        guard let categoryId, let amount = Double(amountText), amount > 0 else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if var existing = expense {
            existing.title = trimmed
            existing.amount = amount
            existing.categoryId = categoryId
            existing.date = date
            existing.note = note
            existing.type = type
            store.updateExpense(existing)
        } else {
            store.addExpense(
                Expense(
                    title: trimmed,
                    amount: amount,
                    categoryId: categoryId,
                    date: date,
                    note: note,
                    type: type
                )
            )
        }
        dismiss()
    }
}
