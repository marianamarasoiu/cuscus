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

  show(CellView cell) {
    element.style.minHeight = '${cell.cellElement.client.height - 2}px';
    element.style.minWidth = '${cell.cellElement.client.width - 4}px';
    element.style.maxHeight = '200px'; // TODO: these should come from the distance between the selected cell and bottom and right margin.
    element.style.maxWidth = '500px';
    element.style.visibility = 'visible';
    element.style.top = '${cell.cellElement.getBoundingClientRect().top - 1}px';
    element.style.left = '${cell.cellElement.getBoundingClientRect().left - 1}px';
    inputElement
      ..text = cell.cellViewModel.formula
      ..focus();
  }

  hide() => element.style.visibility = 'hidden';

  enterKey(String key) => inputElement.text = key;

  positionCursorAtEnd() => window.getSelection().collapse(inputElement, inputElement.text.length);
}
