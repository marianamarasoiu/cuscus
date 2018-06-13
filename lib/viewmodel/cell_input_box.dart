part of cuscus.viewmodel;

class CellInputBoxViewModel {
  view.CellInputBoxView cellInputBoxView;

  CellInputBoxViewModel() {
    cellInputBoxView = new view.CellInputBoxView(this);
  }

  String get contents => cellInputBoxView.contents;

  show(CellViewModel cell) => cellInputBoxView.show(cell.cellView);

  hide() => cellInputBoxView.hide();

  enterKey(String key) => cellInputBoxView.enterKey(key);

  positionCursorAtEnd() => cellInputBoxView.positionCursorAtEnd();
}
