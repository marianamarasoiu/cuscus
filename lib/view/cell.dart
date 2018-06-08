part of cuscus.view;

class CellView {
  TableCellElement cellElement;

  CellViewModel cellViewModel;

  CellView(this.cellViewModel) {
    cellElement = new TableCellElement();
    cellElement.attributes['data-row'] = '${cellViewModel.row}';
    cellElement.attributes['data-col'] = '${cellViewModel.column}';
  }

  String get text => cellElement.text;
  set text(value) => cellElement.text = value;
}
