On-device dictation trigger in the Challenge modal's answer card. `recording` pulses red via a CSS ring animation (declare `@keyframes lat-mic-pulse` in the host page's `<style>` — see UI kit screens). `denied` renders inline warning copy instead of a settings deep-link (no in-app settings screen exists today).

```jsx
<MicButton state="recording" />
```
