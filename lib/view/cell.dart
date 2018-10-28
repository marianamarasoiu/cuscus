part of cuscus.view;

class CellView {
  TableCellElement uiElement;

  viewmodel.CellViewModel cellViewModel;

  CellView(this.cellViewModel) {
    uiElement = new TableCellElement();
    uiElement.attributes['data-row'] = '${cellViewModel.row}';
    uiElement.attributes['data-col'] = '${cellViewModel.column}';
  }

  String get text => uiElement.text;
  set text(value) => uiElement.text = value;
}
