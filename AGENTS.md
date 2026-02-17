# Repository Guidelines

## Project Structure & Module Organization
- Core app code lives in `lib/`, organized by feature: `menu/`, `order/`, `order_overview/`, `calculator/`, `components/`, `utils/`, and `l10n/`.
- Entry point is `lib/main.dart`.
- Platform-specific wrappers are in `android/` and `ios/`.
- Static assets are in `assets/` (declared in `pubspec.yaml`).
- Tests should live in `test/`, mirroring `lib/` paths (for example, `lib/order/order_cubit.dart` -> `test/order/order_cubit_test.dart`).

## Build, Test, and Development Commands
- `fvm flutter pub get`: install Dart/Flutter dependencies.
- `make generate-code`: run localization + code generation (`gen-l10n`, `build_runner`).
- `fvm flutter run`: run locally on simulator/device.
- `fvm flutter analyze`: run static analysis with project lint rules.
- `fvm flutter test`: run test suite.
- `make build-release-android`: clean, fetch deps, generate code, and build Android App Bundle.

## Coding Style & Naming Conventions
- Lint baseline: `flutter_lints` via `analysis_options.yaml`.
- Follow project rule overrides: prefer single quotes; `print` is allowed when needed.
- Use Flutter/Dart conventions:
  - `snake_case` for file names.
  - `PascalCase` for classes/widgets.
  - `camelCase` for methods/variables.
- Keep feature state management in Cubits (`*_cubit.dart`, `*_state.dart`).
- Do not hand-edit generated files such as `*.mapper.dart`, `*.g.dart`, or `lib/l10n/app_localizations*.dart`; regenerate instead.

## Testing Guidelines
- Framework: `flutter_test`.
- Name tests `*_test.dart` and group by feature/module.
- Add tests for business logic changes first (Cubits, validators, formatters), then widget behavior for UI regressions.
- Run `fvm flutter test` and `fvm flutter analyze` before opening a PR.

## Commit & Pull Request Guidelines
- Commit style in history follows Conventional Commit prefixes: `feat:`, `fix:`, `chore:`.
- Keep commits focused and descriptive (for example, `fix: price input formatter edge case`).
- PRs should include:
  - concise summary of behavior changes,
  - linked issue/task when available,
  - screenshots/videos for UI updates,
  - notes on testing performed.
