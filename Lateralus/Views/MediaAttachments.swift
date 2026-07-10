import PencilKit
import SwiftUI

/// Voice-note and drawing controls shared by every place a user answers
/// with more than text — the Challenge modal and Diary entries alike.
/// Two matching pill buttons sit side by side; each expands into its own
/// content (playback controls, or the drawing canvas) once used.
struct MediaAttachments: View {
    let recorder: VoiceNoteRecorder
    let player: VoiceNotePlayer
    @Binding var drawing: PKDrawing
    @Binding var showCanvas: Bool
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                pill(
                    icon: recorder.isRecording ? "stop.fill" : "mic.fill",
                    label: recorder.isRecording
                        ? "Recording · \(voiceNoteDuration(recorder.duration))"
                        : (recorder.fileURL != nil ? "Voice note · \(voiceNoteDuration(recorder.duration))" : "Voice note"),
                    active: recorder.isRecording || recorder.fileURL != nil
                ) {
                    player.stop()
                    recorder.toggle()
                }
                .sensoryFeedback(.impact, trigger: recorder.isRecording)

                pill(
                    icon: "pencil.tip.crop.circle",
                    label: showCanvas ? "Drawing" : (drawing.strokes.isEmpty ? "Add drawing" : "Drawing added"),
                    active: showCanvas || !drawing.strokes.isEmpty
                ) {
                    withAnimation(.snappy) { showCanvas.toggle() }
                }
            }

            if let message = recorderMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else if !recorder.isRecording, let url = recorder.fileURL {
                HStack(spacing: 16) {
                    Button {
                        player.toggle(url: url)
                    } label: {
                        Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title3)
                            .foregroundStyle(tint)
                    }
                    .accessibilityLabel(player.isPlaying ? "Pause voice note" : "Play voice note")

                    Button {
                        player.stop()
                        recorder.discard()
                    } label: {
                        Image(systemName: "trash")
                            .font(.callout)
                            .foregroundStyle(Theme.inkTertiary)
                    }
                    .accessibilityLabel("Delete voice note")
                }
            }

            if showCanvas {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Drawing")
                            .font(.caption.weight(.bold))
                            .textCase(.uppercase)
                            .kerning(1.2)
                            .foregroundStyle(Theme.inkSecondary)
                        Spacer()
                        Button {
                            withAnimation(.snappy) {
                                drawing = PKDrawing()
                                showCanvas = false
                            }
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundStyle(Theme.inkTertiary)
                        }
                        .accessibilityLabel("Remove drawing")
                    }
                    DrawingCanvas(drawing: $drawing)
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    private var recorderMessage: String? {
        switch recorder.state {
        case .denied: "Enable the microphone in Settings"
        case .failed(let message): message
        default: nil
        }
    }

    /// Both controls route through this so they stay pixel-identical:
    /// same capsule, same padding, same icon-and-label layout.
    private func pill(icon: String, label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.callout)
                Text(label)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(active ? Theme.onAccentContainer : tint)
            .background(active ? AnyShapeStyle(tint) : AnyShapeStyle(tint.opacity(0.14)), in: .capsule)
        }
    }
}
