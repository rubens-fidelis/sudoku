# Sudoku

A clean, minimal Sudoku game built with Godot 4. Supports three difficulty levels, pencil marks, mistake tracking, and five languages.

**Engine:** Godot 4.6
**Platforms:** Android · iOS · Windows · macOS · Web

---

## Running the project

1. Open [Godot 4.6](https://godotengine.org/download/) and import the project via `project.godot`
2. Press **F5** (or the Play button) to run

---

## Running tests

Tests use the [GUT](https://github.com/bitwes/Gut) plugin (v9.6.0, bundled in `addons/gut/`).

**In the editor:** open the GUT panel from the bottom dock and click **Run All**.

**From the command line:**
```sh
# All tests
godot --path . -s addons/gut/gut_cmdln.gd

# Single file
godot --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_sudoku.gd
```

Test files:

| File | Covers |
|---|---|
| `tests/test_sudoku.gd` | Puzzle generation, validation, uniqueness |
| `tests/test_game_state.gd` | State management, error counting, pencil marks, win condition |

---

## Exporting

Export presets must be configured in the Godot editor under **Project → Export** before building for any platform. Minimum targets:

| Platform | Requirement |
|---|---|
| Android | SDK 24+, keystore for signing |
| iOS | Xcode on macOS, iOS 14+ |
| macOS | Code signing for App Store distribution |
| Windows | No signing required |
| Web | Host with `SharedArrayBuffer` headers enabled |

App store icons (not included) should be placed in `assets/icons/`:
- `icon_512.png` — Android
- `icon_1024.png` — iOS / macOS

---

## Localization

Translation files live in `locale/`. The master template is `locale/sudoku.pot`.

Supported languages: English · Português (BR) · Español · Français · Deutsch

To add a new language:
1. Copy `locale/sudoku.pot` to `locale/<code>.po`
2. Fill in the `msgstr` values
3. Register the file in `project.godot` under `internationalization/locale/translations`
4. Add the locale code and display name to `LOCALES` / `LOCALE_NAMES` in `scripts/main_menu.gd` and `VALID_LOCALES` in `scripts/game_state.gd`

---

## License

[Add your license here]
