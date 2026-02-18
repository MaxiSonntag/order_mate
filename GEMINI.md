/# OrderMate Project Overview

OrderMate is a Flutter application designed for managing orders and calculations, likely tailored for a business environment such as a restaurant or retail. The application provides robust menu management with import/export features, streamlined order processing, and various calculation functionalities. It leverages `flutter_bloc` for state management, `Hive` for local data persistence, and incorporates custom Material Design theming for its user interface.

## Technologies Used

*   **Framework:** Flutter
*   **Language:** Dart
*   **State Management:** `flutter_bloc`, `hydrated_bloc`
*   **Local Data Storage:** `Hive`
*   **Data Mapping:** `dart_mappable`
*   **File Operations:** `file_picker`, `share_plus`
*   **Code Generation:** `build_runner`, `hive_ce_generator`, `dart_mappable_builder`, `copy_with_extension_gen`, `json_serializable`

## Building and Running

This project uses `fvm` (Flutter Version Management). Ensure `fvm` is set up correctly, or replace `fvm flutter` with `flutter` if you are managing Flutter SDK versions globally.

*   **1. Get Dependencies:**
    ```bash
    fvm flutter pub get
    ```

*   **2. Generate Code:**
    This step is crucial for localization, data mappers, Hive adapters, and other generated files. It should be run whenever data models (`.mapper.dart` files), Hive objects, or localization files (`.arb` files) are changed.
    ```bash
    fvm dart run build_runner build --delete-conflicting-outputs
    ```

*   **3. Run the Application:**
    ```bash
    fvm flutter run
    ```

*   **4. Build Android Release AppBundle:**
    This command cleans the project, fetches dependencies, generates code, and then builds a release appbundle for Android.
    ```bash
    make build-release-android
    ```

## Development Conventions

*   **Code Style & Quality:** The project adheres to `flutter_lints` for consistent code style and quality.
*   **Code Generation:** Extensive use of `build_runner` with various generators (e.g., `hive_ce_generator`, `dart_mappable_builder`, `gen-l10n`) means that developers must execute the `generate-code` step (`fvm dart run build_runner build --delete-conflicting-outputs`) after making changes to data models, Hive objects, or localization files.
*   **State Management:** State logic is implemented using the `flutter_bloc` pattern, with `hydrated_bloc` used for persisting state across application sessions.
*   **Local Persistence:** `Hive` is the chosen solution for local data storage.
*   **UI Theming:** The application utilizes a custom Material Design theme, defining its own `ColorScheme`, `AppBarTheme`, `InputDecorationTheme`, `BottomSheetThemeData`, `CardThemeData`, `OutlinedButtonTheme`, and `ElevatedButtonTheme`.
