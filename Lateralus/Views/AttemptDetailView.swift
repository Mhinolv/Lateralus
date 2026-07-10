import SwiftData
import SwiftUI

/// A saved attempt in full: the original prompt and the user's idea —
/// text, voice note, and drawing alike.
struct AttemptDetailView: View {
    @Bindable var attempt: Attempt
    @Environment(\.modelContext) private var modelContext
    @State private var player = VoiceNotePlayer()
    @State private var persistenceErrorMessage = ""
    @State private var showPersistenceError = false

    var body: some View {
        ZStack {
            AppBackground(accent: attempt.type.tint)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    promptCard
                    responseCard
                }
                .padding(20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(attempt.type.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: attempt.isFavorite ? "star.fill" : "star")
                }
                .tint(.yellow)
            }
        }
        .alert("Journal Update Failed", isPresented: $showPersistenceError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(persistenceErrorMessage)
        }
    }

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Chip(text: attempt.type.title, tint: attempt.type.tint)
                if attempt.isDaily {
                    Badge(kind: .daily, text: "Daily")
                }
                if attempt.isFavorite {
                    Badge(kind: .favorite, text: "Favorite")
                }
                Spacer()
                Text(attempt.date, format: .dateTime.month(.abbreviated).day().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(Theme.inkTertiary)
            }
            Text(attempt.promptPrimary)
                .displayFont(22)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let secondary = attempt.promptSecondary, let label = attempt.challenge.secondaryLabel {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                        .kerning(1.2)
                        .foregroundStyle(attempt.type.tint)
                    Text(secondary)
                        .font(.callout)
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(attempt.type.tint.opacity(0.12), in: .rect(cornerRadius: 14))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    private var responseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your idea")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .kerning(1.2)
                .foregroundStyle(Theme.inkSecondary)
            if !attempt.responseText.isEmpty {
                Text(attempt.responseText)
                    .font(.body)
                    .foregroundStyle(Theme.ink)
                    .textSelection(.enabled)
            }
            if let file = attempt.voiceNoteFile,
               let url = AttachmentStore.live.url(forFile: file),
               AttachmentStore.live.containsVoiceNote(named: file) {
                Button {
                    player.toggle(url: url)
                } label: {
                    Label(
                        player.isPlaying ? "Playing…" : "Play voice note",
                        systemImage: player.isPlaying ? "pause.circle.fill" : "play.circle.fill"
                    )
                    .font(.callout.weight(.medium))
                    .foregroundStyle(attempt.type.tint)
                }
            }
            if let data = attempt.drawingData {
                DrawingImage(data: data)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
        .onDisappear { player.stop() }
    }

    private func toggleFavorite() {
        do {
            try AttemptRepository(context: modelContext).toggleFavorite(attempt)
        } catch {
            persistenceErrorMessage = error.localizedDescription
            showPersistenceError = true
        }
    }
}
