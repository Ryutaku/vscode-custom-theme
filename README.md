# vscode-custom-theme

A mostly theme-neutral desktop interaction layer for VS Code. It refines mouse cursors, word hit-testing, and rounded interaction states, with a consistent interaction palette across dark themes. It can be used with Atom One, One Dark Pro, VSCode Vibrancy Continued, or other themes.

[中文说明](README_zh.md)

## Why this repository exists

VS Code is a desktop application, yet buttons, menus, tabs, and toolbar actions often use the web-style pointing-hand cursor. Even after years of use, that behavior can feel out of place in a traditional desktop interface.

The editor also has a few imprecise interaction details: clicking a word produces a sharp rectangular border, built-in occurrence highlighting marks matching words elsewhere, and punctuation boundaries are not always consistent across full-width and half-width forms.

This repository addresses only those interaction issues. It does not redefine syntax colors, but it does use one consistent set of editor and menu interaction colors across dark themes.

## Features

- Ordinary workbench controls use the default arrow cursor.
- Editable text keeps the I-beam; regular hyperlinks, ARIA links, Monaco links, Welcome-page Start actions, and genuine navigation such as Ctrl+click “go to definition” keep the pointer.
- Clicking a word frames only the instance at the caret.
- The current-word frame is created only by a mouse click; typing, keyboard navigation, and commands clear it instead of making it follow the caret.
- Double-clicking a word selects it with the same rounded border/background as a single-click word frame and changes only the selected word's text to white. Matching words use the same border/background without changing their syntax colors. Triple-click line selection remains native.
- `editor.wordSeparators` is the single source of truth for punctuation boundaries. The supplied setting includes common half-width, Chinese, and full-width punctuation, so clicking `hello` in `hello,你好吗` or `hello，你好吗` frames only `hello`.
- Current-word borders, text selections, and menu hover states have rounded corners.
- Every dark theme uses the same current-word border/background, current-line background, selection background, menu-hover background, and white selected text.
- No `workbench.colorCustomizations`, `editor.tokenColorCustomizations`, or automatic theme switching is included.

## Included files

| Path | Purpose |
|---|---|
| `vscode-custom.css` | Workbench cursor and rounded interaction styles |
| `settings-snippet.jsonc` | Word-boundary, occurrence-highlight, and custom-menu settings |
| `extensions/local.editor-interactions-2.2.0/` | Local extension for settings-driven click, word-selection, and dark-theme selection styling |

## Installation

1. Clone or download this repository.
2. Merge `settings-snippet.jsonc` into your VS Code user `settings.json`; do not replace the entire settings file.
3. Copy `extensions/local.editor-interactions-2.2.0` into `%USERPROFILE%\.vscode\extensions\`.
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
- Dark themes use `#4399F9` / `#033E5D` for the current word, `#2B2D30` for the current line, `#214283` for selections, and `#2A4371` for hovered menu items. Selected text is white. Light themes retain their own interaction colors.
- Current-word punctuation boundaries come exclusively from `editor.wordSeparators`; whitespace remains a natural boundary. Edit that setting to decide whether characters such as `_` or `$` split a word.
- `editor.occurrencesHighlight: "off"` disables automatic highlighting of matching words elsewhere; this is part of the “current word only” behavior.
