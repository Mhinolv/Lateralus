# AGENTS.md

Read this file before you change Lateralus. It is the brief for every agent.

## Product Overview

Lateralus is a private, offline iOS 26 app. It trains lateral thinking with one daily challenge and free practice. It has no account, no analytics, no network calls and no third-party packages.

- Twelve creative games (see `README.md`) plus Diary, a prompt-free entry type. `ChallengeType.games` excludes Diary from rotation and practice.
- A response can hold text, a PencilKit drawing, a voice note (m4a, not transcribed), or any mix.
- Journal: search, favorites, filters, delete. Insights: totals, week activity, streak, balance per game.
- The app does not score creativity. Guidance is a response shape and an optional stretch prompt.
- Removed by owner decision: the AI coach, speech-to-text and the Lateral Puzzle game. Do not add them back without an owner decision.

## Architecture Map

| Area | Files |
|---|---|
| App entry, root tabs | `Lateralus/LateralusApp.swift`, `Lateralus/Views/RootView.swift` |
| Data model, schema | `Lateralus/Models/Attempt.swift` (`LateralusSchemaV1`, `LateralusMigrationPlan`), `Challenge.swift`, `ChallengeType.swift` |
| Prompt content | `Lateralus/Content/*.swift` (curated pools, paired by the engine) |
| Daily schedule, metrics | `Lateralus/Engine/ChallengeEngine.swift` (`scheduleVersion`), `ActivityMetrics.swift` |
| Persistence | `Lateralus/Persistence/AppPersistence.swift`, `AttemptRepository.swift`, `AttachmentStore.swift` |
| Voice notes | `Lateralus/Audio/` |
| Today, challenge, diary | `Lateralus/Views/TodayView.swift`, `ChallengeView.swift`, `DiaryView.swift`, `DrawingCanvas.swift`, `MediaAttachments.swift` |
| Journal, detail | `Lateralus/Views/JournalView.swift`, `AttemptDetailView.swift` |
| Insights | `Lateralus/Views/InsightsView.swift` |
| Theme | `Lateralus/Views/Theme.swift` |
| Tests | `LateralusTests/` (unit), `LateralusUITests/` (UI, `FlowProbeUITests` captures screenshots) |

The project uses Xcode synchronized folder groups. A new file in `Lateralus/` joins the target automatically. Do not edit `project.pbxproj` except for `INFOPLIST_KEY_*` entries.

## Data and Format Rules

- Entries saved before your change must still load. If you change a `@Model`, add a new `VersionedSchema` and a migration stage in `LateralusMigrationPlan`. Never edit `LateralusSchemaV1` in place.
- The daily challenge is a pure function of the date and calendar. If you change the schedule output for a past or future date, bump `ChallengeEngine.scheduleVersion` and keep the no-repeat tests green.
- Stable identifiers (`ChallengeType` raw values, content IDs) are part of the saved format. Do not rename them.
- `AttemptRepository` owns database and file changes together, with rollback. Do not write attachment files from views.

## Design Rules

- Background: deep-space color with aurora. The aurora is the only place for color washes.
- Game cards: flat solid tint per type (`tint` / `onTint`). No gradients anywhere else.
- Other cards: glass material.
- Use SF Symbols for icons. Raw emoji show as empty boxes in the iOS 26 simulator on this Mac.
- Do not use `.ignoresSafeArea(.keyboard, ...)` on a ScrollView. It hides action buttons behind the keyboard.
- Use `PreviewProvider`, not the `#Preview` macro (macros do not run in the engineer sandbox).

## Build and Test

```sh
xcodebuild test -quiet -project Lateralus.xcodeproj -scheme Lateralus \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO
```

UI tests launch with an in-memory database. To read a UI-test failure message, use `xcrun xcresulttool get test-results tests --path <bundle>.xcresult --compact`.

## Team Roadmap Workflow (multi-agent, GitHub)

A multi-agent team works the release milestone in GitHub (`Mhinolv/Lateralus`). GitHub Issues are the single source of truth; every change ships as a pull request into `main`. Everyone writes in ASD-STE100 Simplified Technical English with hard length budgets (see the product-team skill, `~/.claude/writing_standard.md`). Roles:

| Role | Responsibility | Output |
|---|---|---|
| Orchestrator | Supervises, prioritizes, creates issue branches, commits/pushes for the engineer, opens PRs, final approver | Merges PRs, closes issues |
| Product Research | Competitor analysis and gap finding | `research.md` |
| Product Manager | Turns gaps/requests into issues (Problem, Scope & Boundaries, Acceptance criteria) | Issues + `**PM review**` comments |
| UI/UX | `## Design notes` section of each issue | Body section + `**UX notes**` comment |
| Engineer | Implements one issue on its linked branch; regression test first for bugs | Changes + `PR BODY` / `COMMIT FILES` blocks |
| QA | Reviews the PR against the issue's acceptance criteria, design notes and owner decisions | Inline review comments + `QA RESULT: PASS/FAIL` PR comment |

Issue flow labels (exactly one at a time): `needs-pm` → `needs-ux` → `ready` → `in-progress` → `in-review` → (`needs-owner-check`) → closed. Also: `bug`/`feature`, `P0`–`P3`, `owner-request`, `redesign`, `blocked`; PR labels `qa-pass`/`qa-fail`.

Rules:
- Issue bodies use the sections `## Problem / Request`, `## Scope & Boundaries`, `## Acceptance criteria`, `## Design notes`, `## Owner decisions`. Edit one section at a time; never drop the others.
- Product-owner decisions are posted as `**Owner decision:** …` comments and mirrored in `## Owner decisions`; they override earlier wording.
- One issue = one branch (`<n>-<slug>`, created with `gh issue develop`) = one PR into `main`. Commits: `#<n>: <summary>`. Stage only the files changed for that issue. Never `git add -A`. Never commit to main.
- PRs must satisfy the PR template (Issue / What changed / How it was tested / Screenshots). `Refs #n` instead of `Closes #n` while the owner still has to check it.
- CI (build + tests) and the PR-template check must be green before merge.
- The Engineer does not commit, push, open PRs or close issues. QA does not modify source. Only the Orchestrator merges PRs and closes issues.
- For this milestone, **QA PASS + green CI + Orchestrator approval replaces the manual user-test gate** (delegated by the product owner), except issues labelled `needs-owner-check`.
- No agent may use browser/Chrome/computer-use/GUI automation tools.
