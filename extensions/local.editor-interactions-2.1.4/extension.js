const vscode = require('vscode');

function activate(context) {
  const unicodeBoundaryPattern = /[\s\p{P}\p{S}]/u;

  const darkSelectedTextStyle = vscode.window.createTextEditorDecorationType({
    color: '#FFFFFF',
    backgroundColor: '#214283',
    textDecoration: 'none; color: #FFFFFF !important; -webkit-text-fill-color: #FFFFFF !important;',
    rangeBehavior: vscode.DecorationRangeBehavior.OpenOpen,
  });

  const currentWordStyle = vscode.window.createTextEditorDecorationType({
    border: '1px solid',
    borderColor: 'var(--vscode-editor-wordHighlightBorder, var(--vscode-focusBorder))',
    borderRadius: '4px',
    rangeBehavior: vscode.DecorationRangeBehavior.OpenOpen,
    dark: {
      borderColor: '#4399F9',
      backgroundColor: '#033E5D',
    },
  });

  const isWordSeparator = (character) => {
    const separators = vscode.workspace
      .getConfiguration('editor')
      .get('wordSeparators', "`~!@#$%^&*()-=+[{]}\\|;:'\",.<>/?：");
    return unicodeBoundaryPattern.test(character) || separators.includes(character);
  };

  const getCodePointAt = (text, index) => {
    if (index < 0 || index >= text.length) {
      return undefined;
    }

    let start = index;
    const codeUnit = text.charCodeAt(start);
    if (codeUnit >= 0xdc00 && codeUnit <= 0xdfff && start > 0) {
      const previousCodeUnit = text.charCodeAt(start - 1);
      if (previousCodeUnit >= 0xd800 && previousCodeUnit <= 0xdbff) {
        start -= 1;
      }
    }

    const codePoint = text.codePointAt(start);
    return {
      start,
      length: codePoint > 0xffff ? 2 : 1,
      character: String.fromCodePoint(codePoint),
    };
  };

  const getPreviousCodePoint = (text, index) => {
    if (index <= 0) {
      return undefined;
    }
    return getCodePointAt(text, index - 1);
  };

  const getWordRangeAtCursor = (editor, selection) => {
    if (!selection.isEmpty) {
      return undefined;
    }

    const position = selection.active;
    const line = editor.document.lineAt(position.line).text;
    if (!line) {
      return undefined;
    }

    let current = getCodePointAt(line, Math.min(position.character, line.length - 1));
    if (isWordSeparator(current.character)) {
      const previous = getPreviousCodePoint(line, current.start);
      if (!previous || isWordSeparator(previous.character)) {
        return undefined;
      }
      current = previous;
    }

    let start = current.start;
    let previous = getPreviousCodePoint(line, start);
    while (previous && !isWordSeparator(previous.character)) {
      start = previous.start;
      previous = getPreviousCodePoint(line, start);
    }

    let end = current.start + current.length;
    let next = getCodePointAt(line, end);
    while (next && !isWordSeparator(next.character)) {
      end = next.start + next.length;
      next = getCodePointAt(line, end);
    }

    return new vscode.Range(position.line, start, position.line, end);
  };

  const updateSelection = (editor) => {
    if (!editor) {
      return;
    }

    const isDarkTheme =
      vscode.window.activeColorTheme.kind === vscode.ColorThemeKind.Dark ||
      vscode.window.activeColorTheme.kind === vscode.ColorThemeKind.HighContrast;
    const selectedRanges = isDarkTheme
      ? editor.selections
          .filter((selection) => !selection.isEmpty)
          .map((selection) => new vscode.Range(selection.start, selection.end))
      : [];
    editor.setDecorations(darkSelectedTextStyle, selectedRanges);

    const currentWordRanges = editor.selections
      .map((selection) => getWordRangeAtCursor(editor, selection))
      .filter(Boolean);
    editor.setDecorations(currentWordStyle, currentWordRanges);
  };

  context.subscriptions.push(
    darkSelectedTextStyle,
    currentWordStyle,
    vscode.window.onDidChangeTextEditorSelection((event) => {
      updateSelection(event.textEditor);
    }),
    vscode.window.onDidChangeActiveTextEditor((editor) => {
      updateSelection(editor);
    }),
    vscode.workspace.onDidChangeConfiguration((event) => {
      if (event.affectsConfiguration('editor.wordSeparators')) {
        updateSelection(vscode.window.activeTextEditor);
      }
    }),
    vscode.window.onDidChangeActiveColorTheme(() => {
      vscode.window.visibleTextEditors.forEach(updateSelection);
    })
  );

  updateSelection(vscode.window.activeTextEditor);
}

function deactivate() {}

module.exports = { activate, deactivate };
