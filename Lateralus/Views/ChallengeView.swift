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
    @Environment(\.scenePhase) private var scenePhase

    @State private var text = ""
    @State private var connectingWord = ""
    @State private var recorder = VoiceNoteRecorder()
    @State private var player = VoiceNotePlayer()
    @State private var drawing = PKDrawing()
    @State private var showCanvas = false
    @State private var savedAttempt: Attempt?
    @State private var saveErrorMessage = ""
    @State private var showSaveError = false
    @State private var showDiscardConfirmation = false
    @State private var showNewPromptConfirmation = false
    @FocusState private var editorFocused: Bool

    init(challenge: Challenge, isDaily: Bool) {
        _challenge = State(initialValue: challenge)
        self.isDaily = isDaily
    }

    private var isCommonThread: Bool { challenge.type == .wordLink }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(accent: challenge.type.tint)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        instructionBanner
                        promptCard
                        responseGuideCard
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
                    Button("Close") { requestClose() }
                }
                if !isDaily && savedAttempt == nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            requestNewPrompt()
                        } label: {
                            Label("New prompt", systemImage: "dice")
                        }
                    }
                }
            }
        }
        .onChange(of: connectingWord) { _, newValue in
            guard isCommonThread else { return }
            let sanitized = Self.singleWord(from: newValue)
            if sanitized != newValue { connectingWord = sanitized }
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
        .onChange(of: scenePhase) { _, phase in
            guard phase != .active else { return }
            recorder.stop()
            player.stop()
        }
        .interactiveDismissDisabled(hasUnsavedContent)
        .alert("Couldn’t Save", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
        }
        .confirmationDialog(
            "Discard this response?",
            isPresented: $showDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button("Discard Response", role: .destructive) { closeImmediately() }
            Button("Keep Editing", role: .cancel) {}
        }
        .confirmationDialog(
            "Start a new prompt and discard this response?",
            isPresented: $showNewPromptConfirmation,
            titleVisibility: .visible
        ) {
            Button("Discard and Continue", role: .destructive) { loadNewPrompt() }
            Button("Keep This Response", role: .cancel) {}
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

    /// Optional structure that helps a player move beyond the first obvious
    /// answer without turning the exercise into a mandatory form.
    private var responseGuideCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shape your response")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .kerning(1.2)
                .foregroundStyle(challenge.type.tint)

            ForEach(Array(challenge.type.responseGuide.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(challenge.type.onTint)
                        .frame(width: 20, height: 20)
                        .background(challenge.type.tint, in: .circle)
                    Text(item)
                        .font(.subheadline)
                        .foregroundStyle(Theme.inkSecondary)
                }
            }

            if let stretchPrompt = challenge.type.stretchPrompt {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.up.right")
                    Text("Stretch: \(stretchPrompt)")
                }
                .font(.caption)
                .foregroundStyle(Theme.inkTertiary)
                .padding(.top, 2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(challenge.type.tint.opacity(0.08), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(challenge.type.tint.opacity(0.18), lineWidth: 1)
        )
    }

    // MARK: - Input

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            if isCommonThread {
                TextField("Connecting word…", text: $connectingWord)
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

                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("Explain the connection (optional)…")
                            .font(.body)
                            .foregroundStyle(Theme.inkTertiary)
                            .padding(.top, 18)
                            .padding(.leading, 16)
                    }
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                        .frame(minHeight: 100)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                }
                .background(Color.black.opacity(0.25), in: .rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
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

            if !isCommonThread && !text.isEmpty {
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
            if let responseText = savedAttempt?.responseText, !responseText.isEmpty {
                Text(responseText)
                    .font(.body)
                    .foregroundStyle(Theme.ink)
            }
            if let file = savedAttempt?.voiceNoteFile,
               let url = AttachmentStore.live.url(forFile: file) {
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

            Button("Done") { closeImmediately() }
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
        !composedResponseText.isEmpty
            || recorder.fileURL != nil
            || !drawing.strokes.isEmpty
    }

    private var composedResponseText: String {
        let body = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isCommonThread else { return body }

        let word = connectingWord.trimmingCharacters(in: .whitespacesAndNewlines)
        return [word, body].filter { !$0.isEmpty }.joined(separator: "\n\n")
    }

    /// Strips whitespace so the field can only ever hold one word.
    private static func singleWord(from value: String) -> String {
        value.components(separatedBy: .whitespacesAndNewlines).joined()
    }

    private func save() {
        recorder.stop()
        editorFocused = false
        do {
            let attempt = try AttemptRepository(context: modelContext).save(
                challenge: challenge,
                responseText: composedResponseText,
                isDaily: isDaily,
                temporaryVoiceNoteURL: recorder.fileURL,
                drawingData: drawing.strokes.isEmpty ? nil : drawing.dataRepresentation()
            )
            recorder.markCommitted()
            withAnimation(.snappy) { savedAttempt = attempt }
        } catch {
            saveErrorMessage = error.localizedDescription
            showSaveError = true
        }
    }

    private var hasUnsavedContent: Bool {
        savedAttempt == nil && (
            !composedResponseText.isEmpty
                || recorder.fileURL != nil
                || !drawing.strokes.isEmpty
        )
    }

    private func requestClose() {
        if hasUnsavedContent {
            showDiscardConfirmation = true
        } else {
            closeImmediately()
        }
    }

    private func requestNewPrompt() {
        if hasUnsavedContent {
            showNewPromptConfirmation = true
        } else {
            loadNewPrompt()
        }
    }

    private func loadNewPrompt() {
        withAnimation(.snappy) {
            challenge = ChallengeEngine.practice(type: challenge.type)
            text = ""
            connectingWord = ""
            recorder.discard()
            drawing = PKDrawing()
        }
    }

    private func closeImmediately() {
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
