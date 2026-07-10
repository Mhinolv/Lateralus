import PencilKit
import SwiftUI

/// A PencilKit canvas with the system tool picker — the same compact
/// pencil / pen / highlighter / eraser / color toolbar Apple Notes uses.
/// Drawings render on a light "paper" surface so dark inks stay visible
/// against the app's night theme.
struct DrawingCanvas: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = UIColor(white: 0.96, alpha: 1)
        canvas.overrideUserInterfaceStyle = .light
        canvas.delegate = context.coordinator

        let picker = PKToolPicker()
        picker.addObserver(canvas)
        picker.setVisible(true, forFirstResponder: canvas)
        context.coordinator.toolPicker = picker
        DispatchQueue.main.async {
            canvas.becomeFirstResponder()
        }
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
    }

    /// Called when the canvas is removed from the view hierarchy (the
    /// caller toggled its drawing section closed). Without this, the tool
    /// picker is a system-owned overlay window that outlives the view and
    /// keeps floating over whatever's on screen next.
    static func dismantleUIView(_ canvas: PKCanvasView, coordinator: Coordinator) {
        coordinator.toolPicker?.setVisible(false, forFirstResponder: canvas)
        coordinator.toolPicker?.removeObserver(canvas)
        canvas.resignFirstResponder()
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var drawing: Binding<PKDrawing>
        var toolPicker: PKToolPicker?

        init(drawing: Binding<PKDrawing>) {
            self.drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing.wrappedValue = canvasView.drawing
        }
    }
}

/// Read-only rendering of a saved drawing, used in Attempt Detail.
struct DrawingImage: View {
    let data: Data

    var body: some View {
        if let drawing = try? PKDrawing(data: data), !drawing.strokes.isEmpty {
            let bounds = drawing.bounds.insetBy(dx: -16, dy: -16)
            Image(uiImage: drawing.image(from: bounds, scale: 2))
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .background(Color(white: 0.96))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
