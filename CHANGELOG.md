## 0.1.1

- Inline suppression: append `// prism_doctor: ignore <rule>` (or bare `// prism_doctor: ignore`) to bless token-definition files and demo palettes line-by-line.
- Scoring tuned: info findings weigh 0.25 instead of 1.

## 0.1.0

- Initial release: three audit rules (hardcoded colors, magic layout numbers, deprecated material imports).
- Scored report with grade and JSON output for CI gates (`--fail-on`, `--severity`).
