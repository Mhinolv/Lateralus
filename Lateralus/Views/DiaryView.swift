import PencilKit
import SwiftData
import SwiftUI

/// A promptless journal entry: free writing to capture ideas and
/// brainstorms without a game or structured challenge — with the same
/// voice-note and drawing support every challenge answer gets.
struct DiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var text = ""
    @State private var recorder = VoiceNoteRecorder()
    @State private var player = VoiceNotePlayer()
    @State private var drawing = PKDrawing()
    @State private var showCanvas = false
    @State private var saved = false
    @State private var saveErrorMessage = ""
    @State private var showSaveError = false
    @State private var showDiscardConfirmation = false
    @FocusState private var editorFocused: Bool

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || recorder.fileURL != nil
            || !drawing.strokes.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(accent: ChallengeType.diary.tint)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ZStack(alignment: .topLeading) {
                            if text.isEmpty {
                                Text("Whatever's on your mind…")
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
                                .frame(minHeight: 280)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                        }
                        .background(Color.black.opacity(0.25), in: .rect(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        MediaAttachments(
                            recorder: recorder,
                            player: player,
                            drawing: $drawing,
                            showCanvas: $showCanvas,
                            tint: ChallengeType.diary.tint
                        )

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
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Diary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { requestClose() }
                }
            }
            .onAppear { editorFocused = true }
        }
        .onDisappear {
            player.stop()
            // A recording that was never saved shouldn't leave a file behind.
            if saved {
                recorder.stop()
            } else {
                recorder.discard()
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
            "Discard this diary entry?",
            isPresented: $showDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button("Discard Entry", role: .destructive) { closeImmediately() }
            Button("Keep Editing", role: .cancel) {}
        }
    }

    private func save() {
        recorder.stop()
        editorFocused = false
        let entry = Challenge(type: .diary, primary: "Diary", secondary: nil, emoji: "📓")
        do {
            _ = try AttemptRepository(context: modelContext).save(
                challenge: entry,
                responseText: text.trimmingCharacters(in: .whitespacesAndNewlines),
                isDaily: false,
                temporaryVoiceNoteURL: recorder.fileURL,
                drawingData: drawing.strokes.isEmpty ? nil : drawing.dataRepresentation()
            )
            recorder.markCommitted()
            saved = true
            dismiss()
        } catch {
            saveErrorMessage = error.localizedDescription
            showSaveError = true
        }
    }

    private var hasUnsavedContent: Bool {
        !saved && (
            !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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

    private func closeImmediately() {
        player.stop()
        recorder.discard()
        dismiss()
    }
}

#Preview {
    DiaryView()
        .modelContainer(for: Attempt.self, inMemory: true)
        .preferredColorScheme(.dark)
}
