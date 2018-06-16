part of cuscus.view;

class CellInputBoxView {
  DivElement element;
  DivElement inputElement;

  CellInputBoxViewModel cellInputBoxViewModel;

  CellInputBoxView(this.cellInputBoxViewModel) {
    element = querySelector('.input-box'); // TODO: rename element to #cell-input-box
    inputElement = element.querySelector('.cell-input');
  }

  String get contents => inputElement.text;
  set contents (String value) => inputElement.text = value;

  show(CellView cell) {
    element.style
      ..minHeight = '${cell.cellElement.client.height - 2}px'
      ..minWidth = '${cell.cellElement.client.width - 4}px'
      ..maxHeight = '200px' // TODO: these should come from the distance between the selected cell and bottom and right margin.
      ..maxWidth = '500px'
      ..top = '${cell.cellElement.getBoundingClientRect().top - 1}px'
      ..left = '${cell.cellElement.getBoundingClientRect().left - 1}px'
      ..visibility = 'visible';

    inputElement.text = cell.cellViewModel.formula;
  }

  focus() => inputElement.focus();

  hide() => element.style.visibility = 'hidden';

  enterKey(String key) => inputElement.text = key;

  positionCursorAtEnd() => window.getSelection().collapse(inputElement, inputElement.text.length);
}
