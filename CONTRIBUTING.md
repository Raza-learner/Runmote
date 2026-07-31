# Contributing to Runmote

## Code of Conduct

Be respectful, constructive, and inclusive. Harassment, trolling, and entitled demands will not be tolerated.

---

## Rule Set

The following rules apply to every contribution. PRs that break them will be returned with a review comment pointing to the rule number.

### R1 — Branching

1. Base all PRs on `dev`, never `main`.
2. Use short-lived branches with a prefix:
   - `feat/<name>` for features
   - `fix/<name>` for bug fixes
   - `docs/<name>` for documentation
   - `ci/<name>` for CI/CD changes
   - `refactor/<name>` for refactors
3. Delete your branch after merge.
4. `main` is merged from `dev` only, and only for releases.

### R2 — Commit Messages

Use [conventional commits](https://www.conventionalcommits.org/):

```
feat: add local relay URL field to pair screen
fix(daemon): handle empty agent list on startup
docs: add macOS agent support table
ci: add release-desktop workflow
refactor: extract directory picker into reusable widget
```

1. One logical change per commit.
2. Scoped format (`fix(daemon): ...`) is preferred for cross-cutting changes.
3. No `--amend` on shared branches; no force-push to `dev` or `main`.

### R3 — AI-Assisted Code

1. You are allowed to use AI tools (Copilot, ChatGPT, Claude, opencode, etc.) to write code — but **you are responsible for every line** you submit.
2. **Review all AI-generated code before committing.** Understand what it does, why it does it, and how it fits the codebase.
3. AI-generated code must still pass every other rule in this document (R4–R11): lint, tests, no secrets, no debugging artifacts, proper localization.
4. Blatantly un-reviewed AI output — hallucinated APIs, invented files, copy-pasted snippets that don't compile or don't match the codebase — will be **blocked at review**.
5. If asked by a reviewer "did AI write this?", answer honestly. Lying about AI authorship is a PR-blocking offense.
6. Never let AI blindly copy code from another project without checking its license.

### R4 — Secrets & Configuration

1. **Never** commit secrets, tokens, pairing codes, or relay credentials.
2. `.env` is gitignored — never `git add -f` it. If you change `.env`, mirror it in `.env.example`.
3. Relay URLs, hostnames, and public constants go in config/env files, not inline in source.

### R5 — Python (`src/daemon`, `src/relay`, `src/common`)

1. Run `ruff format src/ tests/` and `ruff check src/ tests/` before committing.
2. Line length is **120** (configured in `pyproject.toml`).
3. Use type hints on all public functions.
4. Run `pytest tests/ -v` — all tests must pass.
5. Agent detection changes (in `src/daemon/config.py`) must work on Linux and Windows.
6. No `print()` in production code paths unless flushed for diagnostics (daemon uses `log()`).

### R6 — Dart / Flutter (`src/flutter_app`)

1. Run `flutter analyze --no-fatal-infos` — no errors.
2. Use `const` constructors where possible.
3. Use `.withValues(alpha:)`, not the deprecated `.withOpacity()`.
4. Use Riverpod for state and GoRouter for navigation — no new state-management frameworks.
5. All user-facing strings go through `AppLocalizations` (`l10n`) — no hardcoded UI strings.
6. Add new strings to `lib/l10n/app_en.arb` and run `flutter gen-l10n`.

### R7 — Scripts (`scripts/`)

1. Every bash script starts with `set -euo pipefail`.
2. Use `[[ ]]` for conditionals, lowercase locals, uppercase exported env vars.
3. Shared UI helpers belong in `scripts/lib/ui.sh` — don't redefine colors/messages inline.
4. PowerShell scripts must mirror the bash behavior of the equivalent `.sh`.

### R8 — Desktop app (`desktop/`)

1. Run `cargo check` (Rust) and the frontend type check before committing.
2. Bundled resources go through `tauri.conf.json` — no hardcoded absolute paths.
3. Keep the NSIS/installer workflow intact; don't break the release build.

### R9 — Tests

1. New functionality must include tests where practical.
2. Python tests live in `tests/` and run under `pytest`.
3. Don't delete or weaken existing tests to make yours pass.
4. CI runs on Linux, Windows, and macOS — make sure your change is cross-platform.

### R10 — No Debugging Artifacts

1. No `print()`, `debugPrint`, `console.log`, or leftover comments that were for debugging.
2. No commented-out dead code in PRs.
3. No temporary local paths or absolute machine paths in committed code.

### R11 — PR Hygiene

1. Title describes the change; body explains the why.
2. Link any related issues.
3. Rebase onto `dev` before requesting review if out of date.
4. Respond to review comments promptly; don't resolve threads you didn't address.
5. Keep PRs focused — split unrelated changes into separate PRs.

---

## PR Checklist

- [ ] Branch is based on `dev`
- [ ] Commit messages follow R2
- [ ] AI-assisted code reviewed and understood (R3)
- [ ] `ruff format` + `ruff check` pass (Python changes)
- [ ] `flutter analyze` passes (Flutter changes)
- [ ] `pytest tests/ -v` passes
- [ ] No secrets or `.env` committed (R4)
- [ ] No debugging artifacts (R10)
- [ ] User-facing strings localized via `AppLocalizations` (R6)
- [ ] README updated if agent support, install steps, or platform support changed

---

## Getting Started

```bash
git clone https://github.com/Raza-learner/Runmote.git
cd Runmote
uv sync                              # Python deps (daemon + relay)
cd src/flutter_app && flutter pub get  # Flutter deps
cd ../../desktop && npm install      # Tauri deps (optional)
```

## What Goes Where

| Directory | What | Language | Linter / Test |
|-----------|------|----------|---------------|
| `src/daemon/` | PC daemon (agent bridge) | Python | `ruff` / `pytest` |
| `src/relay/` | WebSocket relay server | Python | `ruff` / `pytest` |
| `src/common/` | Shared Python utils | Python | `ruff` |
| `src/flutter_app/` | Mobile app (Android/iOS) | Dart | `flutter analyze` / `flutter test` |
| `desktop/` | Windows desktop app | Rust + TS | `cargo check` / `tsc` |
| `scripts/` | Install & setup scripts | Bash / PowerShell | `shellcheck` |
| `tests/` | Python test suite | Python | `pytest` |

## Questions?

Open a [discussion](https://github.com/Raza-learner/Runmote/discussions) for questions or ideas before opening an issue.
