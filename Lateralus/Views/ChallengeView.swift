import PencilKit
import SwiftData
import SwiftUI

/// A single challenge session: read the prompt, think, answer by typing,
/// recording a voice note, or sketching — then save.
struct ChallengeView: View {
    @State private var challenge: Challenge
    let isDaily: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var text = ""
    @State private var recorder = VoiceNoteRecorder()
    @State private var player = VoiceNotePlayer()
    @State private var drawing = PKDrawing()
    @State private var showCanvas = false
    @State private var savedAttempt: Attempt?
    @FocusState private var editorFocused: Bool

    init(challenge: Challenge, isDaily: Bool) {
        _challenge = State(initialValue: challenge)
        self.isDaily = isDaily
    }

    /// Common Thread's answer is a single connecting word, not free text.
    private var isSingleWordEntry: Bool { challenge.type == .wordLink }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(accent: challenge.type.tint)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        instructionBanner
                        promptCard
                        if savedAttempt == nil {
                            inputCard
                        } else {
                            savedCard
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(challenge.type.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { close() }
                }
                if !isDaily && savedAttempt == nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation(.snappy) {
                                challenge = ChallengeEngine.practice(type: challenge.type)
                                text = ""
                                recorder.discard()
                                drawing = PKDrawing()
                            }
                        } label: {
                            Label("New prompt", systemImage: "dice")
                        }
                    }
                }
            }
        }
        .onChange(of: text) { _, newValue in
            guard isSingleWordEntry else { return }
            let sanitized = Self.singleWord(from: newValue)
            if sanitized != newValue { text = sanitized }
        }
        .onDisappear {
            player.stop()
            // A recording that was never saved shouldn't leave a file behind.
            if savedAttempt == nil {
                recorder.discard()
            } else {
                recorder.stop()
            }
        }
    }

    // MARK: - Instruction

    /// The standing rule for this discipline, kept visually distinct from
    /// the prompt/topic content below it.
    private var instructionBanner: some View {
        Text(challenge.type.directive)
            .font(.subheadline)
            .foregroundStyle(Theme.inkSecondary)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(challenge.type.tint.opacity(0.10), in: .rect(cornerRadius: 16))
    }

    // MARK: - Prompt

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(challenge.primary)
                .displayFont(26)
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let secondary = challenge.secondary, let label = challenge.secondaryLabel {
                VStack(alignment: .leading, spacing: 6) {
                    Text(label)
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                        .kerning(1.2)
                        .foregroundStyle(challenge.type.tint)
                    Text(secondary)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(challenge.type.tint.opacity(0.12), in: .rect(cornerRadius: 16))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // MARK: - Input

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            if isSingleWordEntry {
                TextField("One word…", text: $text)
                    .focused($editorFocused)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.black.opacity(0.25), in: .rect(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
            } else {
                // Sunken glass: darker recessed fill with an inner hairline,
                // differentiating the editor from the raised prompt card.
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("Type your idea, record it, or sketch it below…")
                            .font(.body)
                            .foregroundStyle(Theme.inkTertiary)
                            .padding(.top, 18)
                            .padding(.leading, 16)
                    }
                    TextEditor(text: $text)
                        .focused($editorFocused)
                        .scrollContentBackground(.hidden)
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                        .frame(minHeight: 160)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                }
                .background(Color.black.opacity(0.25), in: .rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
            }

            MediaAttachments(
                recorder: recorder,
                player: player,
                drawing: $drawing,
                showCanvas: $showCanvas,
                tint: challenge.type.tint
            )

            if !isSingleWordEntry && !text.isEmpty {
                Text("\(wordCount) words")
                    .font(.caption)
                    .foregroundStyle(Theme.inkTertiary)
                    .monospacedDigit()
            }

            Button(action: save) {
                Text("Save to Journal")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        canSave
                            ? AnyShapeStyle(Theme.accentContainer)
                            : AnyShapeStyle(Color.white.opacity(0.08)),
                        in: .capsule
                    )
                    .foregroundStyle(canSave ? Theme.onAccentContainer : Theme.inkTertiary)
            }
            .disabled(!canSave)
        }
        .padding(20)
        .glassCard()
    }

    // MARK: - Saved state

    private var savedCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Saved to your journal", systemImage: "checkmark.seal.fill")
                .font(.headline)
                .foregroundStyle(Theme.success)
            if !text.isEmpty {
                Text(text)
                    .font(.body)
                    .foregroundStyle(Theme.ink)
            }
            if let url = recorder.fileURL {
                Button {
                    player.toggle(url: url)
                } label: {
                    Label(
                        "Voice note · \(voiceNoteDuration(recorder.duration))",
                        systemImage: player.isPlaying ? "pause.circle.fill" : "play.circle.fill"
                    )
                    .font(.callout.weight(.medium))
                    .foregroundStyle(challenge.type.tint)
                }
            }
            if !drawing.strokes.isEmpty {
                DrawingImage(data: drawing.dataRepresentation())
            }

            Button("Done") { close() }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.white.opacity(0.1), in: .capsule)
                .foregroundStyle(Theme.ink)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }

    // MARK: - Actions

    private var wordCount: Int {
        text.split(whereSeparator: \.isWhitespace).count
    }

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || recorder.fileURL != nil
            || !drawing.strokes.isEmpty
    }

    /// Strips whitespace so the field can only ever hold one word.
    private static func singleWord(from value: String) -> String {
        value.components(separatedBy: .whitespacesAndNewlines).joined()
    }

    private func save() {
        recorder.stop()
        editorFocused = false
        let attempt = Attempt(
            challenge: challenge,
            responseText: text.trimmingCharacters(in: .whitespacesAndNewlines),
            isDaily: isDaily
        )
        attempt.voiceNoteFile = recorder.fileURL?.lastPathComponent
        attempt.drawingData = drawing.strokes.isEmpty ? nil : drawing.dataRepresentation()
        modelContext.insert(attempt)
        withAnimation(.snappy) { savedAttempt = attempt }
    }

    private func close() {
        player.stop()
        if savedAttempt == nil {
            recorder.discard()
        } else {
            recorder.stop()
        }
        dismiss()
    }
}

#Preview {
    ChallengeView(challenge: ChallengeEngine.daily(), isDaily: true)
        .modelContainer(for: Attempt.self, inMemory: true)
        .preferredColorScheme(.dark)
}
