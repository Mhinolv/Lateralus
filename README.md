# Lateralus

A beautiful iOS app for strengthening lateral thinking through daily challenges. Everything — your ideas, your voice, the AI coach — stays on your device.

## The eight disciplines

| Discipline | What you do |
|---|---|
| **Alternate Uses** | An everyday object appears; invent a use nobody intended. |
| **Twisted Uses** | Same, but a constraint is applied ("…that helps two strangers meet"). |
| **Reality Shift** | An ordinary scenario runs under one changed rule of reality; think through what breaks, adapts, and becomes possible. |
| **Fusion** | Two unrelated objects/ideas; merge them into one invention or service. |
| **Backstory** | A strange scene; invent the most plausible chain of events that produced it. |
| **Perspective Flip** | Retell an ordinary scenario from an alien point of view (a coin, a security camera, someone's future regret). |
| **Redefine** | A familiar word appears; pretend it never had a meaning and define it fresh. |
| **Coin a Word** | A definition with no English word ("the panic of waving at someone who wasn't waving at you"); invent the word. |

## How it works

- **Daily challenge** — one featured challenge per day, rotating through the eight disciplines. The prompt for a given date is a pure function of the date, generated from combinable content pools (~1,130 hand-curated elements → tens of thousands of combinations). The sequence is guaranteed not to repeat a combination for well over two years (enforced by unit tests).
- **Practice mode** — any discipline, any time, unlimited fresh prompts.
- **Type or speak** — answers can be typed or dictated. Dictation uses `SFSpeechRecognizer` with on-device recognition forced when the hardware supports it; audio never leaves the phone.
- **Journal** — every attempt is stored locally with SwiftData: searchable, favoritable, grouped by day. No account, no network.
- **Insights** — streak, volume, per-discipline balance.
- **AI coach** — after saving an idea, "Expand with on-device AI" asks Apple's on-device foundation model (FoundationModels framework, iOS 26) to name the most original element of your idea and give three provocations that push it further sideways. Runs entirely on-device via Apple Intelligence; the app degrades gracefully when unavailable.

## Architecture

```
Lateralus/
├── Models/        ChallengeType, Challenge (derived, never stored), Attempt (@Model, SwiftData)
├── Content/       ContentLibrary + four pool files (~1,130 curated prompt elements)
├── Engine/        ChallengeEngine — deterministic daily generation, coprime-stride
│                  pool walking so every element is visited before any repeat
├── Speech/        SpeechRecorder — AVAudioEngine + SFSpeechRecognizer, on-device
├── AI/            IdeaCoach — FoundationModels LanguageModelSession wrapper
└── Views/         SwiftUI: Today / Journal / Insights, Theme (night-sky + glass cards)
```

Build: Xcode 26, iOS 26 deployment target, no third-party dependencies. Run `xcodebuild test` for the engine test suite.

## Could SmolLM3 or Phi-4-mini run on a phone?

Yes — both are phone-feasible, but neither is the right first choice for this app.

- **SmolLM3 (3B)**: at 4-bit quantization ≈ **1.8 GB** of weights. Runs on iPhone 15 Pro-class devices (8 GB RAM) via [llama.cpp](https://github.com/ggml-org/llama.cpp) or Apple's [MLX Swift](https://github.com/ml-explore/mlx-swift-examples); ~15–30 tok/s decode on recent A-series chips.
- **Phi-4-mini (3.8B)**: at 4-bit ≈ **2.3 GB**. Same story, slightly slower; comfortable on 8 GB devices, tight on 6 GB ones.

The practical costs: a 2 GB+ download inside the app bundle or on first launch, meaningful battery/thermal load, and you maintain the inference stack. Since this app targets iOS 26, **Apple's Foundation Models framework** gives a ~3B-parameter on-device model for free — no download, no memory pressure on the app, private by default — which is what `IdeaCoach` uses. If a bundled open model is ever wanted (e.g., to support devices without Apple Intelligence), the clean path is MLX Swift with a 4-bit SmolLM3, behind the same `IdeaCoach` interface.
