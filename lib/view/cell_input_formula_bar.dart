part of cuscus.view;

class CellInputFormulaBarView {
  DivElement element;

  CellInputFormulaBarViewModel cellInputFormulaBarViewModel;

  CellInputFormulaBarView(this.cellInputFormulaBarViewModel) {
    element = querySelector('#formula-editor');
  }

  String get contents => element.text;
  set contents (String value) => element.text = value;

  focus() => element.focus();
  unfocus() => element.blur();

  enterKey(String key) => element.text = key;

  positionCursorAtEnd() => window.getSelection().collapse(element, element.text.length);
}
