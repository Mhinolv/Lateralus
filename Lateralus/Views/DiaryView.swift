import PencilKit
import SwiftData
import SwiftUI

/// A promptless journal entry: free writing to capture ideas and
/// brainstorms without a game or structured challenge — with the same
/// voice-note and drawing support every challenge answer gets.
struct DiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var text = ""
    @State private var recorder = VoiceNoteRecorder()
    @State private var player = VoiceNotePlayer()
    @State private var drawing = PKDrawing()
    @State private var showCanvas = false
    @State private var saved = false
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
                    Button("Close") { close() }
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
    }

    private func save() {
        recorder.stop()
        editorFocused = false
        let entry = Challenge(type: .diary, primary: "Diary", secondary: nil, emoji: "📓")
        let attempt = Attempt(
            challenge: entry,
            responseText: text.trimmingCharacters(in: .whitespacesAndNewlines),
            isDaily: false
        )
        attempt.voiceNoteFile = recorder.fileURL?.lastPathComponent
        attempt.drawingData = drawing.strokes.isEmpty ? nil : drawing.dataRepresentation()
        modelContext.insert(attempt)
        saved = true
        dismiss()
    }

    private func close() {
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
