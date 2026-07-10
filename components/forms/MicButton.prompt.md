Voice-note recording control in the Challenge and Diary response cards. Recordings remain audio attachments and are not transcribed. `recording` pulses red via a CSS ring animation (declare `@keyframes lat-mic-pulse` in the host page's `<style>`). `denied` renders inline warning copy instead of a settings deep-link.

```jsx
<MicButton state="recording" />
```
