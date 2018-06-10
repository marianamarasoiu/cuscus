part of cuscus.viewmodel;

class CellViewModel {
  int row;
  int column;

  String _userEnteredFormula = '';
  String _value = '';

  SheetViewModel sheetViewModel;
  view.CellView cellView;

  CellViewModel(this.row, this.column, this.sheetViewModel);

  createView(Element parent) {
    cellView = new view.CellView(this);
    parent.append(cellView.cellElement);
  }

  set _text(String value) {
    _value = value;
    cellView.text = value;
  }

  String get value => _value;
  String get formula => _userEnteredFormula;

  void commitFormula(String formula) {
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    String jsonParseTree = parser.parseFormula(formula);
    Map formulaParseTree = JSON.decode(jsonParseTree);
    var elementsResolvedTree = resolveSymbols(formulaParseTree, activeSheet.id, spreadsheetEngine);
    addNodeToSpreadsheetEngine(elementsResolvedTree, cell, spreadsheetEngine);

    // Propagate the changes in the dependency graph.
    spreadsheetEngine.depGraph.update();

    // Update contents of current cell
    engine.SpreadsheetDepNode node = spreadsheetEngine.cells[cell];
    node.onChange.listen((_) => _text = node.computedValue.value.toString());
    _text = node.computedValue.value.toString();

    // Hide the cell editing box
    cellInputBoxViewModel.hide();

    // Save a copy of the formula for later
    _userEnteredFormula = formula;
  }
}
