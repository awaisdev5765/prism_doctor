# prism_doctor

[![pub package](https://img.shields.io/pub/v/prism_doctor.svg)](https://pub.dev/packages/prism_doctor)

**Design-system audit CLI for Flutter/Dart projects.** Scores your codebase
for design-system health and gates CI on regressions.

## What it checks

| Rule | Severity | Meaning |
|---|---|---|
| `no_hardcoded_colors` | warning | `Color(0x…)` literals should be theme colors or tokens |
| `no_magic_numbers` | info | Raw `EdgeInsets.all(16)`-style values bypass spacing tokens |
| `no_deprecated_material_import` | warning | `package:flutter/material.dart` → `package:material_ui` (Flutter 3.50) |

## Usage

```sh
dart global activate prism_doctor
prism_doctor .                 # audit current project
prism_doctor . --json          # machine-readable (CI-friendly)
prism_doctor . --fail-on error # only fail on errors
prism_doctor . --severity warning
```

## Output

```
prism doctor — design system audit
root: /work/app  |  files scanned: 84

lib/theme/colors.dart
  warning 12:9  no_hardcoded_colors: hardcoded color Color(0xFF1A73E8)

score: 88/100  grade: B  (errors: 0, warnings: 1, info: 6)
```

## CI gate

```yaml
- run: dart global activate prism_doctor && prism_doctor . --fail-on error
```

## Part of the Prism ecosystem

`prism_kit` (62-component adaptive UI kit) · `prism_glass` (Liquid Glass) ·
`prism_sketch` (code generator) · `prism_guardrails` (AI guardrails) ·
`prism_doctor` (this auditor) · `urdu_toolkit`
