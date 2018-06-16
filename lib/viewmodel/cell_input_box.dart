part of cuscus.viewmodel;

class CellInputBoxViewModel {
  view.CellInputBoxView cellInputBoxView;

  CellInputBoxViewModel() {
    cellInputBoxView = new view.CellInputBoxView(this);
  }

  setupListeners() {
    cellInputFormulaBarViewModel.onInput.listen(
      (_) => contents = cellInputFormulaBarViewModel.contents);
  }

  Stream get onInput => cellInputBoxView.inputElement.onInput;

  String get contents => cellInputBoxView.contents;
  set contents (String value) => cellInputBoxView.contents = value;

  show(CellViewModel cell) => cellInputBoxView.show(cell.cellView);

  focus() => cellInputBoxView.focus();

  hide() => cellInputBoxView.hide();

  enterKey(String key) {
    cellInputBoxView.enterKey(key);
    cellInputFormulaBarViewModel.contents = contents;
  }

  positionCursorAtEnd() => cellInputBoxView.positionCursorAtEnd();
}
