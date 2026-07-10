# Lateralus — Design Handoff

## App Summary

Lateralus is an iOS app (SwiftUI + SwiftData, iOS 26) that trains lateral thinking through short daily creativity challenges. Each day the app serves one deterministic "daily" prompt from a large curated content library (~810 elements, combinatorially paired so prompts don't repeat for years), plus unlimited free-practice prompts across 8 challenge disciplines. Users respond by typing or dictating (on-device speech-to-text), save their answer to a private journal, and can optionally ask an on-device AI coach (Apple FoundationModels / Apple Intelligence) to push their idea further. Everything is stored locally on-device — no accounts, no network calls, no analytics.

The app currently runs **dark-mode only**, with a "night sky" gradient backdrop, glassmorphism cards, and a distinct color/icon identity per challenge type. There is no onboarding flow and no in-app settings screen (permission issues are handled with inline text pointing to iOS Settings).

## Structure

3-tab app, each tab its own navigation stack:

1. **Today** — home / daily challenge / practice picker
2. **Journal** — history of saved answers
3. **Insights** — stats dashboard

Challenges open as a modal sheet from Today; Journal entries push to a detail screen.

---

## Pages / Screens

### 1. Today
The home screen.
- Header: date, streak pill (flame icon + day count), headline "Think sideways."
- **Daily Card**: hero card for today's featured challenge — type chip, icon, prompt text, optional constraint/twist/pairing panel, "Begin" / "Answer again" button, completed-checkmark state. Tapping opens the Challenge modal.
- **Practice grid**: 2-column grid, one card per challenge type (icon, title, one-line blurb). Tapping generates a fresh practice prompt of that type and opens the Challenge modal.

### 2. Challenge (modal)
The core "do a challenge" screen, opened as a sheet.
- **Before saving**: prompt card (directive, icon, prompt text, optional secondary panel) + input card (text editor, mic button for dictation, live word count, "Save to Journal" button). Toolbar has close (X) and, for practice prompts, a "new prompt" dice button.
- **After saving**: confirmation state showing the saved response (read-only), a "Coach" section (button to run AI coach, loading state, or displayed coaching notes), and a "Done" button.
- 8 challenge types, each with its own icon/color identity: Alternate Uses, Twisted Uses, Reality Shift, Fusion, Backstory, Perspective Flip, Redefine, Coin a Word. Four of these (Twisted Uses, Reality Shift, Fusion, Perspective Flip) show an extra highlighted "modifier" panel (constraint / twist / merge-with / perspective).

### 3. Journal
List of every saved answer, grouped by day.
- Row: type icon, prompt text, daily/favorite badges, 2-line response preview.
- Search bar (filters by response, prompt, or type).
- Favorites-only filter toggle (star, top-right).
- Swipe left to delete, swipe right to favorite.
- Empty state and search-empty state.
- Tapping a row pushes to Attempt Detail.

### 4. Attempt Detail
Full read view of one past entry (pushed from Journal).
- Prompt card (type, timestamp, prompt, modifier panel if applicable).
- Response card (full, selectable text).
- Coach card — either shows previously-generated coach notes, or a button to generate them if not yet run.
- Favorite toggle in toolbar.

### 5. Insights
Read-only stats dashboard (no interactive controls at all).
- 3 stat tiles: day streak, total ideas, this week's count.
- "Discipline balance": horizontal bar chart of attempt counts across the 8 challenge types.
- "The road ahead": text card estimating how many years of unique daily prompts remain in the content library.
- "Private by design" card: explains on-device storage/speech/AI, plus a live status line for AI coach availability (ready / unavailable + reason).

---

## Key Features

- **Daily challenge**: one deterministic prompt per day, no repeats for ~years, shared by all users on a given date.
- **Free practice**: unlimited randomly-generated prompts across 8 disciplines, on demand.
- **8 challenge types**, each with distinct icon, 2-color gradient, and directive copy:
  | Type | Icon | Has modifier panel |
  |---|---|---|
  | Alternate Uses | branch arrow | no |
  | Twisted Uses | link+ | yes (constraint) |
  | Reality Shift | sparkles | yes (the twist) |
  | Fusion | grid/cross | yes (merge with) |
  | Backstory | magnifying glass | no |
  | Perspective Flip | eye | yes (seen by) |
  | Redefine | quote | no |
  | Coin a Word | text/abc | no |
- **Voice input**: tap-to-record dictation (on-device speech recognition) that streams transcribed text directly into the answer field; visual recording state (pulsing red mic) and inline permission-denied messaging.
- **On-device AI coach**: optional, on-demand "Expand with on-device AI" action (Apple Intelligence/FoundationModels) that reacts to a saved answer with a short response — one sentence of praise plus 3 provocations to push the idea further. Surfaced in the Challenge modal, Attempt Detail, and status-only in Insights.
- **Journal**: full history, search, favoriting, swipe-to-delete — the only persistent data store in the app.
- **Streaks & stats**: streak pill, total idea count, weekly count, per-discipline distribution chart — all read-only, computed from journal data.
- **Privacy messaging**: explicit in-app copy that everything (storage, speech recognition, AI coaching) happens on-device with no network dependency.

## Notes for the Designer

- **No settings screen exists** — permission problems (mic, speech, Apple Intelligence unavailable) currently just show inline warning text. This may be worth a real settings/preferences screen.
- **No onboarding flow** — first launch drops straight into Today.
- **Dark mode only today** — there is no light palette; a light mode would need to be designed from scratch if desired.
- **App icon / launch screen** — not covered in this pass (lives in asset catalogs, not app source); flag separately if needed.
- Each `PromptItem` in the content library carries an **emoji field that is stored but never displayed** in the current UI (SF Symbols are used instead) — a candidate area to revisit, e.g. using the emoji as an alternate/additional icon treatment.
- Current visual language: full-bleed dark gradient background with soft colored "aurora" glows tinted to the active challenge type, glassmorphic cards (translucent fill, thin border, large corner radius), serif display type for prompts/headlines, sans-serif for body/UI chrome.
