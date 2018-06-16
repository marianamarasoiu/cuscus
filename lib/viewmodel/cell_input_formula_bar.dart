part of cuscus.viewmodel;

class CellInputFormulaBarViewModel {
  view.CellInputFormulaBarView cellInputFormulaBarView;

  CellInputFormulaBarViewModel() {
    cellInputFormulaBarView = new view.CellInputFormulaBarView(this);
  }

  setupListeners() {
    cellInputBoxViewModel.onInput.listen(
      (_) => contents = cellInputBoxViewModel.contents);
  }

  Stream get onInput => cellInputFormulaBarView.element.onInput;

  String get contents => cellInputFormulaBarView.contents;
  set contents (String value) => cellInputFormulaBarView.contents = value;

  focus() => cellInputFormulaBarView.focus();
  unfocus() => cellInputFormulaBarView.unfocus();

  enterKey(String key) {
    cellInputFormulaBarView.enterKey(key);
    cellInputBoxViewModel.contents = contents;
  }

  positionCursorAtEnd() => cellInputFormulaBarView.positionCursorAtEnd();
}
