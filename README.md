# vscode-custom-theme

A theme-neutral desktop interaction layer for VS Code. It no longer overrides theme colors; it only refines mouse cursors, word hit-testing, and rounded interaction states. It can be used with Atom One, VSCode Vibrancy Continued, or any other theme.

[中文说明](README_zh.md)

## Why this repository exists

VS Code is a desktop application, yet buttons, menus, tabs, and toolbar actions often use the web-style pointing-hand cursor. Even after years of use, that behavior can feel out of place in a traditional desktop interface.

The editor also has a few imprecise interaction details: clicking a word produces a sharp rectangular border, built-in occurrence highlighting marks matching words elsewhere, and the full-width Chinese colon `：` is not always treated as the desired word boundary.

This repository addresses only those interaction issues and leaves all color decisions to the active theme.

## Features

- Ordinary workbench controls use the default arrow cursor.
- Editable text keeps the I-beam; regular hyperlinks, ARIA links, Monaco links, Welcome-page Start actions, and genuine navigation such as Ctrl+click “go to definition” keep the pointer.
- Clicking a word frames only the instance at the caret.
- The full-width Chinese colon `：` acts as a word separator, so clicking `root` in `账号密码：root` does not include the preceding label.
- Current-word borders, text selections, and menu hover states have rounded corners.
- Menu, selection, text, cursor, and border colors are inherited from the active VS Code theme.
- No `workbench.colorCustomizations`, `editor.tokenColorCustomizations`, or automatic theme switching is included.

## Included files

| Path | Purpose |
|---|---|
| `vscode-custom.css` | Workbench cursor and rounded interaction styles |
| `settings-snippet.jsonc` | Word-boundary, occurrence-highlight, and custom-menu settings |
| `extensions/local.precise-current-word-2.0.0/` | Local extension that frames only the word at the caret |

## Installation

1. Clone or download this repository.
2. Merge `settings-snippet.jsonc` into your VS Code user `settings.json`; do not replace the entire settings file.
3. Copy `extensions/local.precise-current-word-2.0.0` into `%USERPROFILE%\.vscode\extensions\`.
4. Choose one CSS loading method.

### Load with VSCode Vibrancy Continued

Add this to `settings.json`:

```jsonc
"vscode_vibrancy.imports": [
    "D:/path/to/vscode-custom-theme/vscode-custom.css"
]
```

Run **Reload Vibrancy**, fully exit VS Code, and start it again.

### Load with Custom CSS and JS Loader

Add this to `settings.json`:

```jsonc
"vscode_custom_css.imports": [
    "file:///D:/path/to/vscode-custom-theme/vscode-custom.css"
],
"vscode_custom_css.policy": true
```

Run **Enable Custom CSS and JS** or **Reload Custom CSS and JS**, then run **Developer: Reload Window**.

Choose only one loading method so the same CSS is not injected twice.

## VS Code upgrades

A VS Code upgrade may replace workbench files patched by the CSS loader or Vibrancy, but it does not change this repository. After upgrading, run the relevant loader's Reload command and restart VS Code.

The CSS relies on VS Code's workbench DOM and may require selector updates after a major UI change.

## Notes

- This repository does not require or install any color theme.
- The local extension uses the active theme's `editor.wordHighlightBorder` color and defines no custom color value.
- `editor.occurrencesHighlight: "off"` disables automatic highlighting of matching words elsewhere; this is part of the “current word only” behavior.
