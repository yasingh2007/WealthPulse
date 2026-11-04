import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var showEditor = false
    @State private var editingCategory: ExpenseCategory?

    private let iconOptions = [
        "fork.knife", "car.fill", "house.fill", "bolt.fill", "bag.fill",
        "film.fill", "heart.fill", "banknote.fill", "ellipsis.circle.fill",
        "airplane", "gift.fill", "book.fill", "dumbbell.fill", "pawprint.fill",
        "cart.fill", "phone.fill", "gamecontroller.fill", "cup.and.saucer.fill"
    ]

    private let colorOptions = [
        "E07A5F", "3D5A80", "81B29A", "F2CC8F", "D62828",
        "457B9D", "EF476F", "06D6A0", "6C757D", "FF6B6B",
        "118AB2", "073B4C", "F77F00", "2A9D8F"
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.categories) { category in
                    Button {
                        editingCategory = category
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(category.color.opacity(0.18))
                                    .frame(width: 44, height: 44)
                                Image(systemName: category.icon)
                                    .foregroundStyle(category.color)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.name)
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                                    .foregroundStyle(Theme.ink)
                                Text(category.isDefault ? "Built-in" : "Custom")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(Theme.muted)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.muted.opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Theme.surface)
                    .swipeActions {
                        if !category.isDefault {
                            Button(role: .destructive) {
                                store.deleteCategory(category)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingCategory = nil
                        showEditor = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                CategoryEditorSheet(
                    category: nil,
                    iconOptions: iconOptions,
                    colorOptions: colorOptions
                )
            }
            .sheet(item: $editingCategory) { category in
                CategoryEditorSheet(
                    category: category,
                    iconOptions: iconOptions,
                    colorOptions: colorOptions
                )
            }
        }
    }
}

private struct CategoryEditorSheet: View {
    @EnvironmentObject private var store: FinanceStore
    @Environment(\.dismiss) private var dismiss

    let category: ExpenseCategory?
    let iconOptions: [String]
    let colorOptions: [String]

    @State private var name = ""
    @State private var icon = "tag.fill"
    @State private var colorHex = "0F7A5F"

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                        .disabled(category?.isDefault == true)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { option in
                            Button {
                                icon = option
                            } label: {
                                Image(systemName: option)
                                    .foregroundStyle(icon == option ? .white : Color(hex: colorHex))
                                    .frame(width: 40, height: 40)
                                    .background(icon == option ? Color(hex: colorHex) : Color(hex: colorHex).opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Button {
                                colorHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 30, height: 30)
                                    .overlay {
                                        if colorHex == hex {
                                            Image(systemName: "checkmark")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(category == nil ? "New Category" : "Edit Category")
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
            .onAppear {
                if let category {
                    name = category.name
                    icon = category.icon
                    colorHex = category.colorHex
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if var existing = category {
            if !existing.isDefault {
                existing.name = trimmed
            }
            existing.icon = icon
            existing.colorHex = colorHex
            store.updateCategory(existing)
        } else {
            store.addCategory(
                ExpenseCategory(name: trimmed, icon: icon, colorHex: colorHex)
            )
        }
        dismiss()
    }
}
