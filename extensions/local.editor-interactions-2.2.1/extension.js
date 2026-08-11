const vscode = require('vscode');

function activate(context) {
  const editorsWithMouseWordFrame = new WeakSet();
  const editorsWithMouseWordSelection = new WeakSet();

  const darkSelectedTextStyle = vscode.window.createTextEditorDecorationType({
    color: '#FFFFFF',
    backgroundColor: '#214283',
    borderRadius: '4px',
    textDecoration: 'none; color: #FFFFFF !important; -webkit-text-fill-color: #FFFFFF !important;',
    rangeBehavior: vscode.DecorationRangeBehavior.OpenOpen,
  });

  const selectedWordStyle = vscode.window.createTextEditorDecorationType({
    color: '#FFFFFF',
    backgroundColor: 'var(--vscode-editor-wordHighlightBackground, var(--vscode-editor-selectionBackground))',
    border: '1px solid',
    borderColor: 'var(--vscode-editor-wordHighlightBorder, var(--vscode-focusBorder))',
    borderRadius: '4px',
    textDecoration: 'none; color: #FFFFFF !important; -webkit-text-fill-color: #FFFFFF !important;',
    rangeBehavior: vscode.DecorationRangeBehavior.OpenOpen,
    dark: {
      backgroundColor: '#033E5D',
      borderColor: '#4399F9',
    },
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
      .get('wordSeparators', "`~!@#$%^&*()-=+[{]}\\|;:'\",.<>/?，。；：！？、（）【】［］｛｝《》〈〉“”‘’「」『』〔〕…—·～￥＂＃＄％＆＇＊＋－．／＜＝＞＠＼＾＿｀｜");
    return /\s/u.test(character) || separators.includes(character);
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

  const getExactSelectedWordRange = (editor, selection) => {
    if (selection.isEmpty || selection.start.line !== selection.end.line) {
      return undefined;
    }

    const caretAtStart = new vscode.Selection(selection.start, selection.start);
    const wordRange = getWordRangeAtCursor(editor, caretAtStart);
    const selectedRange = new vscode.Range(selection.start, selection.end);
    return wordRange?.isEqual(selectedRange) ? selectedRange : undefined;
  };

  const getMatchingWordRanges = (editor, selectedWordRanges) => {
    const selectedKeys = new Set(
      selectedWordRanges.map(
        (range) =>
          `${range.start.line}:${range.start.character}-${range.end.line}:${range.end.character}`
      )
    );
    const words = [
      ...new Set(
        selectedWordRanges
          .map((range) => editor.document.getText(range))
          .filter(Boolean)
      ),
    ];
    const matches = [];
    const matchKeys = new Set();

    for (const word of words) {
      for (let lineNumber = 0; lineNumber < editor.document.lineCount; lineNumber += 1) {
        const line = editor.document.lineAt(lineNumber).text;
        let searchFrom = 0;
        while (searchFrom <= line.length - word.length) {
          const index = line.indexOf(word, searchFrom);
          if (index === -1) {
            break;
          }

          const end = index + word.length;
          const before = getPreviousCodePoint(line, index);
          const after = getCodePointAt(line, end);
          const hasWordBoundaries =
            (!before || isWordSeparator(before.character)) &&
            (!after || isWordSeparator(after.character));
          const key = `${lineNumber}:${index}-${lineNumber}:${end}`;
          if (
            hasWordBoundaries &&
            !selectedKeys.has(key) &&
            !matchKeys.has(key)
          ) {
            matches.push(
              new vscode.Range(lineNumber, index, lineNumber, end)
            );
            matchKeys.add(key);
          }
          searchFrom = end;
        }
      }
    }

    return matches;
  };

  const updateSelection = (editor) => {
    if (!editor) {
      return;
    }

    const isDarkTheme =
      vscode.window.activeColorTheme.kind === vscode.ColorThemeKind.Dark ||
      vscode.window.activeColorTheme.kind === vscode.ColorThemeKind.HighContrast;
    const hasMouseWordSelection = editorsWithMouseWordSelection.has(editor);
    const selectedWordRanges = hasMouseWordSelection
      ? editor.selections
          .map((selection) => getExactSelectedWordRange(editor, selection))
          .filter(Boolean)
      : [];
    const selectedRanges = isDarkTheme
      ? editor.selections
          .filter(
            (selection) =>
              !selection.isEmpty &&
              !(hasMouseWordSelection && getExactSelectedWordRange(editor, selection))
          )
          .map((selection) => new vscode.Range(selection.start, selection.end))
      : [];
    editor.setDecorations(darkSelectedTextStyle, selectedRanges);
    editor.setDecorations(selectedWordStyle, selectedWordRanges);

    const currentWordRanges = editorsWithMouseWordFrame.has(editor)
      ? editor.selections
          .map((selection) => getWordRangeAtCursor(editor, selection))
          .filter(Boolean)
      : [];
    const matchingWordRanges = hasMouseWordSelection
      ? getMatchingWordRanges(editor, selectedWordRanges)
      : [];
    editor.setDecorations(
      currentWordStyle,
      currentWordRanges.concat(matchingWordRanges)
    );
  };

  context.subscriptions.push(
    darkSelectedTextStyle,
    selectedWordStyle,
    currentWordStyle,
    vscode.window.onDidChangeTextEditorSelection((event) => {
      const isMouseWordClick =
        event.kind === vscode.TextEditorSelectionChangeKind.Mouse &&
        event.selections.every((selection) => selection.isEmpty);
      const isMouseWordSelection =
        event.kind === vscode.TextEditorSelectionChangeKind.Mouse &&
        event.selections.every((selection) =>
          Boolean(getExactSelectedWordRange(event.textEditor, selection))
        );
      if (isMouseWordClick) {
        editorsWithMouseWordFrame.add(event.textEditor);
      } else {
        editorsWithMouseWordFrame.delete(event.textEditor);
      }
      if (isMouseWordSelection) {
        editorsWithMouseWordSelection.add(event.textEditor);
      } else {
        editorsWithMouseWordSelection.delete(event.textEditor);
      }
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
    vscode.workspace.onDidChangeTextDocument((event) => {
      vscode.window.visibleTextEditors
        .filter((editor) => editor.document === event.document)
        .forEach((editor) => {
          editorsWithMouseWordFrame.delete(editor);
          editorsWithMouseWordSelection.delete(editor);
          updateSelection(editor);
        });
    }),
    vscode.window.onDidChangeActiveColorTheme(() => {
      vscode.window.visibleTextEditors.forEach(updateSelection);
    })
  );

  updateSelection(vscode.window.activeTextEditor);
}

function deactivate() {}

module.exports = { activate, deactivate };
