# Lateralus — Design Handoff

## Product summary

Lateralus is a dark-mode iOS 26 app for short lateral-thinking exercises. It offers one deterministic daily prompt, unlimited practice across twelve creative games, and a prompt-free Diary. Entries may contain text, a drawing, a recorded voice note, or any combination. Voice recordings are attachments and are not converted to text. The product has no AI coach, account, analytics, or network calls.

The visual language is a night-sky gradient, restrained glass surfaces, editorial display type, and a distinct solid tint/icon identity for each game. User data is stored locally with SwiftData and the app attachment directory.

## Structure

The app has three tabs, each with its own navigation stack:

1. **Today** — current date, streak, daily challenge, and practice picker.
2. **Journal** — saved entries, Diary creation, search, filters, favorites, and deletion.
3. **Insights** — activity totals, calendar-week count, trailing-seven-day chart, and game balance.

Challenges and Diary open as sheets. Journal entries push to a detail screen.

## Screens

### Today

- Date, day-streak pill, and “Think sideways.” headline.
- Daily hero card with game, prompt, optional modifier, completion state, and Begin/Answer Again action.
- Two-column practice grid containing all twelve games.

### Challenge sheet

- Prompt card with directive, icon, prompt, and an optional secondary modifier.
- Compact game-specific response guidance and an optional stretch prompt.
- Response editor with text, word count, optional drawing canvas, and optional voice-note recorder.
- Common Thread separates its single connecting word from an optional explanation.
- Voice recording displays duration, stops at five minutes, handles interruptions, and can be discarded before save.
- Save requires at least text, a drawing, or a voice note.
- Closing or requesting a new prompt confirms before discarding unsaved content.
- After save, the response and attachments are read-only with a Done action.

### Journal and Diary

- Entries are grouped by local day and show type, prompt, preview, and attachment/favorite/daily indicators.
- Search covers response, prompt, modifier, and type.
- Filters include all twelve games plus Diary; a separate toggle shows favorites only.
- Swipe actions favorite or delete an entry.
- The new-entry toolbar action opens a prompt-free Diary sheet with the same text, drawing, and voice-note options.

### Attempt detail

- Prompt/type/date, selectable response text, drawing, and voice-note playback.
- Favorite toggle and destructive delete action.
- Unknown stored type identifiers remain visibly labeled instead of being silently remapped.

### Insights

- Day streak, total journal entries, and current calendar-week count.
- “Last 7 days” entry chart.
- Discipline balance for the twelve playable games. Diary and unknown entry types do not appear in this chart, though they count toward activity/streak totals.

## Game identities

| Game | Symbol intent | Modifier |
|---|---|---|
| Alternate Uses | branching arrow | none |
| Twisted Uses | linked plus | constraint |
| Reality Shift | sparkles | changed rule |
| Fusion | joined grid | second concept |
| Backstory | magnifying text | none |
| Perspective Flip | eye | viewpoint |
| Redefine | quotation | none |
| Coin a Word | alphabet | none |
| Common Thread | connected points | second word |
| Positive Spin | turning arrow | none |
| Inventions | light bulb | none |
| Mini Mythology | scroll | none |

Diary uses a book-pages identity and is deliberately outside the game rotation.

## Content and interaction guidance

- Keep language warm, concise, and encouraging without presenting an automated coach persona.
- Empty states should describe the next useful action.
- Use SF Symbols for UI chrome and game identities; prompt emoji is stored content, not chrome.
- Use numerals for counts and durations.
- Animation should communicate state: press feedback, recording pulse, save transition, and numeric changes. Avoid decorative motion.
- Permission copy refers only to microphone access for recording voice notes.
- Privacy copy must be literal: entries and attachments stay in the app container, and the app has no network feature.

## Known product boundaries

- Dark mode only.
- No onboarding or settings screen.
- Microphone denial is explained inline with direction to iOS Settings.
- App icon and generated launch screen live in the asset catalog/project settings.
