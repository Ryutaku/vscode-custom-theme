# vscode-custom-theme

A reusable VS Code customization for Atom One Dark and Atom One Light. It combines theme-scoped colors, rounded menu states, desktop-style mouse cursors, theme-aware selected-text colors, and precise word highlighting.

[中文说明](README_zh.md)

## Features

- Atom One Dark keeps the blue palette used by the original setup.
- Atom One Light uses a green UI palette with a deep-yellow editor selection and cursor.
- Menu items use rounded hover backgrounds while submenus remain correctly scoped.
- Editor selection text stays white in both themes.
- Clicking a word highlights only that word, including text separated by the full-width Chinese colon `：`.
- Editor text keeps the I-beam cursor; ordinary workbench controls use the default arrow.
- Theme colors coexist and can follow the Windows light/dark mode automatically.

## Included files

| Path | Purpose |
|---|---|
| `vscode-custom.css` | Workbench cursor, menu, rounded-corner, and editor visual overrides |
| `settings-snippet.jsonc` | Theme-scoped VS Code settings to merge into the user settings file |
| `extensions/local.selection-white-1.2.1/` | Local extension for theme-aware selected text and exact current-word borders |

## Installation

1. Install the [Atom One Dark Theme](https://marketplace.visualstudio.com/items?itemName=akamud.vscode-theme-onedark), [Atom One Light Theme](https://marketplace.visualstudio.com/items?itemName=akamud.vscode-theme-onelight), and [Custom CSS and JS Loader](https://marketplace.visualstudio.com/items?itemName=be5invis.vscode-custom-css).
2. Clone or download this repository.
3. Merge the contents of `settings-snippet.jsonc` into your VS Code user `settings.json`. Do not replace your complete settings file.
4. Change `vscode_custom_css.imports` to the absolute `file:///` URL of your local `vscode-custom.css`.
5. Copy `extensions/local.selection-white-1.2.1` into `%USERPROFILE%\.vscode\extensions\`.
6. Run **Enable Custom CSS and JS** or **Reload Custom CSS and JS** from the command palette.
7. Run **Developer: Reload Window**.

## Palette

| Context | Atom One Dark | Atom One Light |
|---|---:|---:|
| Main accent | `#0078D4` | `#198754` |
| Menu hover | `#2B50AA` | `#D1E7DD` |
| Editor selection | `#2B50AA` | `#E09D00` |
| Cursor and current-word border | `#0078D4` | `#E09D00` |

## VS Code upgrades

VS Code upgrades replace the generated `workbench.html`. The source files in this repository remain valid. After an upgrade, run **Reload Custom CSS and JS** again and restart VS Code.

Custom CSS selectors depend on VS Code's workbench DOM and may need adjustment after a major UI change.

## Notes

- `settings-snippet.jsonc` contains only settings related to this customization; it intentionally excludes accounts, credentials, license values, server addresses, and command history.
- The local extension disables the built-in occurrence highlight and replaces it with a precise word border based on `editor.wordSeparators`.
