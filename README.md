# Lateralus

Lateralus is a private, offline iOS app for strengthening lateral thinking through daily challenges and free writing. It has no account, analytics, network dependency, speech-to-text, or AI coach.

## Creative games

The daily rotation and practice grid contain twelve games:

| Game | What you do |
|---|---|
| **Alternate Uses** | Find a use nobody intended. |
| **Twisted Uses** | Reinvent an object under a constraint. |
| **Reality Shift** | Follow the consequences of one changed rule. |
| **Fusion** | Merge two unrelated concepts into one essential idea. |
| **Backstory** | Explain the chain of events behind a strange scene. |
| **Perspective Flip** | Retell an ordinary situation from an alien viewpoint. |
| **Redefine** | Give a familiar word a fresh meaning. |
| **Coin a Word** | Invent a word for a missing definition. |
| **Common Thread** | Find and explain one link between two words. |
| **Positive Spin** | Turn a terrible idea into something useful. |
| **Inventions** | Invent a confidently wrong explanation for an object. |
| **Mini Mythology** | Write the myth behind an everyday inconvenience. |

Diary is a thirteenth, prompt-free journal entry type. It is not part of the daily game rotation.

## Product behavior

- **Daily challenge** — one deterministic prompt per local calendar day. The versioned schedule walks the full advertised combination space without repeating within two years.
- **Practice** — generate a fresh prompt for any of the twelve games.
- **Flexible responses** — save text, a PencilKit drawing, a voice-note recording, or any combination of them. Voice notes are recordings attached to entries; they are not transcribed.
- **Journal** — local SwiftData history with search, favorites, filtering, deletion, and recoverable startup.
- **Insights** — entry totals, calendar-week activity, trailing seven days, streak, and per-game balance. Diary entries count as creative activity but not as a game discipline.
- **Privacy** — data stays in the app container. The application contains no networking or third-party dependencies.

## Architecture

```text
Lateralus/
├── Models/        Versioned SwiftData schema and stable challenge identifiers
├── Content/       Curated prompt pools
├── Engine/        Versioned deterministic generation and activity metrics
├── Persistence/   Recoverable container, transactional repository, attachment store
├── Audio/         Bounded voice-note recording and playback
└── Views/         SwiftUI Today, Journal, Insights, challenge, diary, and detail flows
```

SwiftData owns entry metadata. The attachment store owns voice-note files, and `AttemptRepository` coordinates database/file operations with rollback and startup reconciliation. Drawing data uses SwiftData external storage. Daily generation is pure for a supplied date and calendar; UI day changes are refreshed on activation, calendar rollover, and time-zone changes.

## Build and test

Requirements: Xcode 26 or newer and iOS 26. The project uses Swift 6 and has no package dependencies.

```sh
xcodebuild build \
  -project Lateralus.xcodeproj \
  -scheme Lateralus \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO

xcodebuild test \
  -project Lateralus.xcodeproj \
  -scheme Lateralus \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

The shared scheme runs unit and UI tests. UI tests launch with an isolated in-memory database. GitHub Actions repeats the Release build and complete test suite on the `macos-26` runner.

Before App Store submission, configure the distribution signing profile/team in Xcode and archive the `Lateralus` scheme against a generic iOS device.
