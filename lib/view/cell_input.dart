part of cuscus.view;

class CellInputBoxView {
  DivElement element;
  DivElement inputElement;

  CellInputBoxView() {
    element = querySelector('#cell-input-editor-container');
    inputElement = element.querySelector('#cell-input-editor');
  }

  String get contents => inputElement.text;
  set contents (String value) => inputElement.text = value;

  show(CellView cell) {
    element.style
      ..minHeight = '${cell.uiElement.client.height - 2}px'
      ..minWidth = '${cell.uiElement.client.width - 4}px'
      ..maxHeight = '200px'
      ..maxWidth = '500px'
      ..top = '${cell.uiElement.getBoundingClientRect().top - 1}px'
      ..left = '${cell.uiElement.getBoundingClientRect().left - 1}px'
      ..visibility = 'visible';

    inputElement.text = cell.cellViewModel.formula;
  }

  focus() => inputElement.focus();

  hide() => element.style.visibility = 'hidden';

  enterKey(String key) => inputElement.text = key;

  positionCursorAtEnd() => window.getSelection().collapse(inputElement, inputElement.text.length);
}

class CellInputFormulaBarView {
  DivElement element;

  CellInputFormulaBarView() {
    element = querySelector('#formula-editor');
  }

  String get contents => element.text;
  set contents (String value) => element.text = value;

  focus() => element.focus();
  unfocus() => element.blur();

  enterKey(String key) => element.text = key;

  positionCursorAtEnd() => window.getSelection().collapse(element, element.text.length);
}
