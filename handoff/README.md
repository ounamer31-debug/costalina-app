# Costalina — Handoff Bundle

Unzip this folder into the **root of your Flutter app** (the directory
with `pubspec.yaml`). All paths below are relative to that root.

## What's inside

```
handoff/
├── Claude Code Handoff.md       ← THE INSTRUCTIONS. Read this first.
├── Costalina Prototype.html     ← Visual source of truth. Open in a browser.
├── screens.jsx                  ← React mirror of every widget to build.
├── icons.jsx                    ← Stroke-icon definitions (Lucide-style).
├── ios-frame.jsx                ← Phone bezel for the prototype only — ignore.
└── assets/
    └── brand/
        ├── costalina-logo.jpg   ← 720×720 master logo (use on splash/about).
        └── costalina-mark.svg   ← Recolorable vector mark (use everywhere else).
```

## How to use it with Claude Code

1. Drop this `handoff/` folder into your Flutter repo root.
2. From a terminal in that repo, run `claude`.
3. Paste this prompt:

> Read `handoff/Claude Code Handoff.md` from top to bottom, then implement
> it PR by PR following section §13. Open `handoff/Costalina Prototype.html`
> alongside as the visual source of truth — when the doc and the prototype
> disagree, the prototype wins. Confirm the rename pass (§2) is complete
> before touching visuals. Stop after each PR and show me the diff before
> moving on.

4. After PR 1 merges, you can move `costalina-logo.jpg` and
   `costalina-mark.svg` out of `handoff/assets/brand/` into your real
   `assets/brand/` directory if Claude Code hasn't already done so, and
   delete the `handoff/` folder entirely once the implementation lands.

## QA

Use the **Acceptance checklist (§11)** in the handoff doc as your
review script for every PR.
