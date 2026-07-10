import SwiftUI

/// Celestial Nocturne: a deep-space canvas with aurora glows tinted to the
/// active challenge, frosted-glass surfaces, serif display type, and a
/// single violet accent for global actions.
enum Theme {
    /// Deep Space — the bottom-most layer under every screen.
    static let deepSpace = Color(hex: 0x050508)
    static let ink = Color(hex: 0xE5E1E4)
    static let inkSecondary = Color(hex: 0xC7C4D7).opacity(0.85)
    static let inkTertiary = Color(hex: 0x918FA0)
    /// Hairline card edge — frost, not shadow.
    static let cardStroke = Color.white.opacity(0.12)
    static let cardStrokeActive = Color.white.opacity(0.30)
    static let glassFill = Color(hex: 0x1E1E23).opacity(0.4)
    /// Global accent (streaks, primary buttons, links).
    static let accent = Color(hex: 0xC2C1FF)
    static let accentContainer = Color(hex: 0x5E5CE6)
    static let onAccentContainer = Color(hex: 0xF4F1FF)
    static let success = Color(hex: 0x38EF7D)
}

/// Full-screen backdrop: Deep Space solid with soft aurora glows that
/// take on the active challenge type's color.
struct AppBackground: View {
    var accent: Color = Theme.accentContainer

    var body: some View {
        Theme.deepSpace
            .overlay {
                Circle()
                    .fill(accent.opacity(0.32))
                    .frame(width: 460)
                    .blur(radius: 130)
                    .offset(x: -140, y: -320)
            }
            .overlay {
                Circle()
                    .fill(Theme.accentContainer.opacity(0.18))
                    .frame(width: 400)
                    .blur(radius: 120)
                    .offset(x: 170, y: 360)
            }
            .ignoresSafeArea()
    }
}

/// Frosted-glass surface: backdrop blur, translucent fill, and a 12%-white
/// hairline border instead of a shadow. Main cards use the 24pt radius.
struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 24
    var active = false

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Theme.glassFill)
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(active ? Theme.cardStrokeActive : Theme.cardStroke, lineWidth: 1)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 24, active: Bool = false) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, active: active))
    }

    /// Serif display style used for prompts and headers.
    func displayFont(_ size: CGFloat, weight: Font.Weight = .semibold) -> some View {
        font(.system(size: size, weight: weight, design: .serif))
    }
}

/// Small capsule label, used for challenge-type tags and secondary chips.
struct Chip: View {
    let text: String
    var tint: Color = .white

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .kerning(1.1)
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(tint.opacity(0.14), in: .capsule)
    }
}

/// Compact, high-contrast pill celebrating consistency — primary fill.
struct StreakPill: View {
    let days: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundStyle(days > 0 ? Theme.onAccentContainer : Theme.onAccentContainer.opacity(0.55))
            Text(days == 1 ? "1 day" : "\(days) days")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.onAccentContainer)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Theme.accentContainer, in: .capsule)
        .overlay(Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 1))
    }
}

/// Small pill tag marking a Journal row or Attempt Detail entry as the
/// daily prompt or a favorite.
struct Badge: View {
    enum Kind { case daily, favorite }

    let kind: Kind
    let text: String

    private var tint: Color {
        switch kind {
        case .daily: Theme.accent
        case .favorite: .yellow
        }
    }

    private var symbol: String {
        switch kind {
        case .daily: "sun.max.fill"
        case .favorite: "star.fill"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 10, weight: .bold))
            Text(text)
                .font(.system(size: 11, weight: .bold))
                .textCase(.uppercase)
                .kerning(0.4)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8)
        .frame(height: 22)
        .background(tint.opacity(0.16), in: .capsule)
    }
}
