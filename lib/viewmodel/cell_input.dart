part of cuscus.viewmodel;

void setupCellInput() {
  CellInputBoxViewModel.setupListeners();
  CellInputFormulaBarViewModel.setupListeners();
}

class CellInputBoxViewModel {
  static view.CellInputBoxView cellInputBoxView = new view.CellInputBoxView();

  CellInputBoxViewModel._();

  static setupListeners() {
    CellInputFormulaBarViewModel.onInput.listen((_) => contents = CellInputFormulaBarViewModel.contents);
  }

  static Stream get onInput => cellInputBoxView.inputElement.onInput;

  static String get contents => cellInputBoxView.contents;
  static set contents (String value) => cellInputBoxView.contents = value;

  static show(CellViewModel cell) => cellInputBoxView.show(cell.cellView);
  static focus() => cellInputBoxView.focus();
  static hide() => cellInputBoxView.hide();

  static enterKey(String key) {
    cellInputBoxView.enterKey(key);
    CellInputFormulaBarViewModel.contents = contents;
  }

  static positionCursorAtEnd() => cellInputBoxView.positionCursorAtEnd();
}


class CellInputFormulaBarViewModel {
  static view.CellInputFormulaBarView cellInputFormulaBarView = new view.CellInputFormulaBarView();

  CellInputFormulaBarViewModel._();

  static setupListeners() {
    CellInputBoxViewModel.onInput.listen((_) => contents = CellInputBoxViewModel.contents);
  }

  static Stream get onInput => cellInputFormulaBarView.element.onInput;

  static String get contents => cellInputFormulaBarView.contents;
  static set contents (String value) => cellInputFormulaBarView.contents = value;

  static focus() => cellInputFormulaBarView.focus();
  static unfocus() => cellInputFormulaBarView.unfocus();

  static enterKey(String key) {
    cellInputFormulaBarView.enterKey(key);
    CellInputBoxViewModel.contents = contents;
  }

  static positionCursorAtEnd() => cellInputFormulaBarView.positionCursorAtEnd();
}
