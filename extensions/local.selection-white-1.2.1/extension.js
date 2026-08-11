const vscode = require('vscode');

function activate(context) {
  const selectedTextStyle = vscode.window.createTextEditorDecorationType({
    color: new vscode.ThemeColor('selectionWhite.selectedForeground'),
    rangeBehavior: vscode.DecorationRangeBehavior.OpenOpen,
  });

  const currentWordStyle = vscode.window.createTextEditorDecorationType({
    border: '1px solid',
    borderColor: new vscode.ThemeColor('editor.wordHighlightBorder'),
    borderRadius: '4px',
    rangeBehavior: vscode.DecorationRangeBehavior.OpenOpen,
  });

  const isWordSeparator = (character) => {
    const separators = vscode.workspace
      .getConfiguration('editor')
      .get('wordSeparators', "`~!@#$%^&*()-=+[{]}\\|;:'\",.<>/?：");
    return /\s/u.test(character) || separators.includes(character);
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

    let index = Math.min(position.character, line.length - 1);
    if (isWordSeparator(line[index])) {
      if (index === 0 || isWordSeparator(line[index - 1])) {
        return undefined;
      }
      index -= 1;
    }

    let start = index;
    let end = index + 1;
    while (start > 0 && !isWordSeparator(line[start - 1])) {
      start -= 1;
    }
    while (end < line.length && !isWordSeparator(line[end])) {
      end += 1;
    }

    return new vscode.Range(position.line, start, position.line, end);
  };

  const updateSelection = (editor) => {
    if (!editor) {
      return;
    }

    const selectedRanges = editor.selections
      .filter((selection) => !selection.isEmpty)
      .map((selection) => new vscode.Range(selection.start, selection.end));
    editor.setDecorations(selectedTextStyle, selectedRanges);

    const currentWordRanges = editor.selections
      .map((selection) => getWordRangeAtCursor(editor, selection))
      .filter(Boolean);
    editor.setDecorations(currentWordStyle, currentWordRanges);
  };

  context.subscriptions.push(
    selectedTextStyle,
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
    })
  );

  updateSelection(vscode.window.activeTextEditor);
}

function deactivate() {}

module.exports = { activate, deactivate };
