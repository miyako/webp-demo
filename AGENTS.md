# AGENTS.md — webp-demo

Interactive 4D demo of `miyako/webp` 20.0.0. This repository is a *host
project* for the released component, not the component itself.

## Ground rules

- The component dependency is pinned in `Project/Sources/dependencies.json`
  (`webp` 20.0.0 from GitHub). Never vendor `Components/webp.4dbase/` into
  Git; it is built from the release asset.
- macOS only. The 20.0.0 asset is a universal macOS binary. Never describe
  Windows support as working.
- Plain 4D code, no token suffixes (`tokenizedText: false`).

## Skills

`.agents/` is the [`miyako/skills`](https://github.com/miyako/skills)
submodule (branch `dist`). Consult these before changing behavior:

- `4dproject` — project files, `.gitignore`, dependency conventions
- `4dform` — form JSON schema and CSS (validated with `fourdform`)
- `4dlang` — language pitfalls: `File()` paths, `Choose()` eagerness,
  `Storage`/`Use`, number/string concatenation
- `4dcli` — headless runs and the screenshot chain
- `4dstartup` — `CALL WORKER` + `DIALOG(…; *)` startup pattern

## Verification

- Headless: `tool4d --project Project/webp-demo.4DProject
  --startup-method=Studio_SelfTest --dataless --skip-onstartup`
  (21 checks; writes `selftest-report.json`).
- Analyzer: `tools/4dlsp/tool4d-lsp-stdio validate --workspace Project …`.
  `cs.WebP` unknown-class warnings are expected from the vendored component.
- Screenshots: full 4D only (no `tool4d`, no `--headless`), running
  `CaptureScreenshots` with `--user-param "<action>:<page>:<path>.png"`.

## Findings are part of the deliverable

The README records the observed failures (stderr diagnostics reported as
`protocol/invalid_protocol`, `inspect()` not decoding, `output.mode` being
a path, the TIFF/GIF page asymmetry). Keep those claims in sync with
`Studio_SelfTest` — if a check is removed, the README claim goes too.
