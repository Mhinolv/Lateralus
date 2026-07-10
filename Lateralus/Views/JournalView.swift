import SwiftData
import SwiftUI

/// Every past challenge and answer, stored on-device, searchable, and
/// filterable by challenge type.
struct JournalView: View {
    @Query(sort: \Attempt.date, order: .reverse) private var attempts: [Attempt]
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var favoritesOnly = false
    @State private var typeFilter: ChallengeType?
    @State private var showDiary = false
    @State private var persistenceErrorMessage = ""
    @State private var showPersistenceError = false

    private var filtered: [Attempt] {
        attempts.filter { attempt in
            if favoritesOnly && !attempt.isFavorite { return false }
            if let typeFilter, attempt.type != typeFilter { return false }
            guard !searchText.isEmpty else { return true }
            return attempt.responseText.localizedCaseInsensitiveContains(searchText)
                || attempt.promptPrimary.localizedCaseInsensitiveContains(searchText)
                || (attempt.promptSecondary?.localizedCaseInsensitiveContains(searchText) ?? false)
                || attempt.type.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var grouped: [(day: Date, items: [Attempt])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.date) }
        return groups.keys.sorted(by: >).map { (day: $0, items: groups[$0]!) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                if attempts.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDiary = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("New diary entry")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    filterMenu
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.snappy) { favoritesOnly.toggle() }
                    } label: {
                        Image(systemName: favoritesOnly ? "star.fill" : "star")
                    }
                    .tint(.yellow)
                    .accessibilityLabel(favoritesOnly ? "Show all" : "Show favorites only")
                }
            }
        }
        .sheet(isPresented: $showDiary) {
            DiaryView()
        }
        .alert("Journal Update Failed", isPresented: $showPersistenceError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(persistenceErrorMessage)
        }
    }

    /// Filter the journal down to one challenge type.
    private var filterMenu: some View {
        Menu {
            Picker("Challenge type", selection: $typeFilter) {
                Text("All types").tag(ChallengeType?.none)
                ForEach(ChallengeType.journalFilters) { type in
                    Label(type.title, systemImage: type.symbol)
                        .tag(ChallengeType?.some(type))
                }
            }
        } label: {
            Image(systemName: typeFilter == nil
                ? "line.3.horizontal.decrease.circle"
                : "line.3.horizontal.decrease.circle.fill")
        }
        .accessibilityLabel("Filter by challenge type")
    }

    private var list: some View {
        List {
            ForEach(grouped, id: \.day) { group in
                Section {
                    ForEach(group.items) { attempt in
                        NavigationLink(value: attempt.id) {
                            JournalRow(attempt: attempt)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .swipeActions(edge: .leading) {
                            Button {
                                toggleFavorite(attempt)
                            } label: {
                                Image(systemName: attempt.isFavorite ? "star.slash" : "star.fill")
                            }
                            .tint(.yellow)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                delete(attempt)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                } header: {
                    Text(group.day, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.inkSecondary)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText, prompt: "Search prompts and ideas")
        .navigationDestination(for: UUID.self) { id in
            if let attempt = attempts.first(where: { $0.id == id }) {
                AttemptDetailView(attempt: attempt)
            }
        }
        .overlay {
            if filtered.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No entries yet", systemImage: "book.closed")
        } description: {
            Text("Finish a challenge and it will live here — every idea stays on this device.")
        }
    }

    /// Removes the attempt and any voice note file it owns.
    private func delete(_ attempt: Attempt) {
        do {
            try AttemptRepository(context: modelContext).delete(attempt)
        } catch {
            persistenceErrorMessage = error.localizedDescription
            showPersistenceError = true
        }
    }

    private func toggleFavorite(_ attempt: Attempt) {
        do {
            try AttemptRepository(context: modelContext).toggleFavorite(attempt)
        } catch {
            persistenceErrorMessage = error.localizedDescription
            showPersistenceError = true
        }
    }
}

struct JournalRow: View {
    let attempt: Attempt

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: attempt.type.symbol)
                .font(.callout)
                .foregroundStyle(attempt.type.tint)
                .frame(width: 34, height: 34)
                .background(attempt.type.tint.opacity(0.15), in: .circle)
            VStack(alignment: .leading, spacing: 4) {
                Text(attempt.promptPrimary)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                if attempt.isDaily || attempt.isFavorite || attempt.voiceNoteFile != nil || attempt.drawingData != nil {
                    HStack(spacing: 6) {
                        if attempt.isDaily {
                            Badge(kind: .daily, text: "Daily")
                        }
                        if attempt.isFavorite {
                            Badge(kind: .favorite, text: "Favorite")
                        }
                        if attempt.voiceNoteFile != nil {
                            Image(systemName: "waveform")
                                .font(.caption2)
                                .foregroundStyle(Theme.inkTertiary)
                        }
                        if attempt.drawingData != nil {
                            Image(systemName: "scribble.variable")
                                .font(.caption2)
                                .foregroundStyle(Theme.inkTertiary)
                        }
                    }
                }
                Text(attempt.responseText)
                    .font(.caption)
                    .foregroundStyle(Theme.inkSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 20)
    }
}

#Preview {
    JournalView()
        .modelContainer(for: Attempt.self, inMemory: true)
        .preferredColorScheme(.dark)
}
