import SwiftUI

struct NetWorthView: View {
    @EnvironmentObject private var store: FinanceStore
    @State private var showEditor = false
    @State private var editingEntry: NetWorthEntry?

    private var latest: NetWorthEntry? {
        store.netWorthEntries.last
    }

    private var change: Double? {
        guard store.netWorthEntries.count >= 2 else { return nil }
        let last = store.netWorthEntries[store.netWorthEntries.count - 1].netWorth
        let prev = store.netWorthEntries[store.netWorthEntries.count - 2].netWorth
        return last - prev
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    summaryHeader
                    NetWorthTrendChart(entries: store.netWorthEntries)
                    historyList
                }
                .padding(16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Net Worth")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingEntry = nil
                        showEditor = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                NetWorthEditorView()
            }
            .sheet(item: $editingEntry) { entry in
                NetWorthEditorView(entry: entry)
            }
        }
    }

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Net Worth")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
                .textCase(.uppercase)
                .tracking(0.7)

            Text(Formatters.money(latest?.netWorth ?? 0))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                labeledValue("Assets", Formatters.money(latest?.assets ?? 0))
                labeledValue("Liabilities", Formatters.money(latest?.liabilities ?? 0))
                if let change {
                    labeledValue(
                        "Change",
                        (change >= 0 ? "+" : "") + Formatters.money(change)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Theme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.accent.opacity(0.3), radius: 14, y: 6)
    }

    private func labeledValue(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundStyle(.white)
        }
    }

    private var historyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Snapshots")
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(Theme.ink)

            if store.netWorthEntries.isEmpty {
                Text("Log assets and liabilities to track your net worth over time.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Theme.muted)
            } else {
                ForEach(store.netWorthEntries.reversed()) { entry in
                    Button {
                        editingEntry = entry
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Formatters.shortDate.string(from: entry.date))
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                                    .foregroundStyle(Theme.ink)
                                Text("Assets \(Formatters.money(entry.assets)) · Debt \(Formatters.money(entry.liabilities))")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(Theme.muted)
                            }
                            Spacer()
                            Text(Formatters.money(entry.netWorth))
                                .font(.system(.body, design: .rounded).weight(.bold))
                                .foregroundStyle(Theme.accent)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            store.deleteNetWorth(entry)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }

                    if entry.id != store.netWorthEntries.first?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(18)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Theme.cardShadow, radius: 10, y: 4)
    }
}

struct NetWorthEditorView: View {
    @EnvironmentObject private var store: FinanceStore
    @Environment(\.dismiss) private var dismiss

    var entry: NetWorthEntry?

    @State private var date = Date()
    @State private var assetsText = ""
    @State private var liabilitiesText = ""
    @State private var note = ""
    @State private var showDelete = false

    private var canSave: Bool {
        (Double(assetsText) ?? -1) >= 0 && (Double(liabilitiesText) ?? -1) >= 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Snapshot") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Assets", text: $assetsText)
                        .keyboardType(.decimalPad)
                    TextField("Liabilities", text: $liabilitiesText)
                        .keyboardType(.decimalPad)
                }

                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }

                if entry != nil {
                    Section {
                        Button("Delete Snapshot", role: .destructive) {
                            showDelete = true
                        }
                    }
                }
            }
            .navigationTitle(entry == nil ? "Add Snapshot" : "Edit Snapshot")
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
                if let entry {
                    date = entry.date
                    assetsText = String(format: "%.2f", entry.assets)
                    liabilitiesText = String(format: "%.2f", entry.liabilities)
                    note = entry.note
                } else if let latest = store.netWorthEntries.last {
                    assetsText = String(format: "%.2f", latest.assets)
                    liabilitiesText = String(format: "%.2f", latest.liabilities)
                }
            }
            .confirmationDialog("Delete this snapshot?", isPresented: $showDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let entry {
                        store.deleteNetWorth(entry)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func save() {
        let assets = Double(assetsText) ?? 0
        let liabilities = Double(liabilitiesText) ?? 0
        if var existing = entry {
            existing.date = date
            existing.assets = assets
            existing.liabilities = liabilities
            existing.note = note
            store.updateNetWorth(existing)
        } else {
            store.addNetWorth(
                NetWorthEntry(date: date, assets: assets, liabilities: liabilities, note: note)
            )
        }
        dismiss()
    }
}
