part of cuscus.viewmodel;

class CellViewModel {
  int row;
  int column;

  String _userEnteredFormula = '';
  engine.CellContents cellContents = null;
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

  void commitFormulaString(String formula) {
    String jsonParseTree = parser.parseFormula(formula);
    Map formulaParseTree = JSON.decode(jsonParseTree);
    engine.CellContents cellContents = resolveSymbols(formulaParseTree, activeSheet.id, spreadsheetEngine);

    commitFormula(cellContents);

    // TODO fix hack
    if (sheetViewModel is GraphicsSheetViewModel) {
      GraphicsSheetViewModel sheet = sheetViewModel;
      if (!sheet.layerViewModel.shapes.containsKey(row)) {
        sheet.fillInRow(this);
      }
    }
  }

  void commitFormula(engine.CellContents cellContents) {
    this.cellContents = cellContents;
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    addNodeToSpreadsheetEngine(cellContents, cell, spreadsheetEngine);

    // Propagate the changes in the dependency graph.
    spreadsheetEngine.depGraph.update();

    // Update contents of current cell and set listeners
    setupListenersForCell();
  }

  update() {
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    engine.SpreadsheetDepNode node = spreadsheetEngine.cells[cell];
    cellContents = node.value;

    setupListenersForCell();

    cellView.cellElement.classes.add('flash');
    new Timer(new Duration(seconds: 1), () => cellView.cellElement.classes.remove('flash'));
  }

  setupListenersForCell() {
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    engine.SpreadsheetDepNode node = spreadsheetEngine.cells[cell];
    cellContents = node.value;

    _text = node.computedValue.value.toString();
    _userEnteredFormula = stringifyFormula(cellContents, sheetViewModel.id, spreadsheetEngine);

    node.onChange.listen((_) {
      engine.SpreadsheetDepNode node = spreadsheetEngine.cells[cell];
      cellContents = node.value;

      _text = node.computedValue.value.toString();
      _userEnteredFormula = stringifyFormula(cellContents, sheetViewModel.id, spreadsheetEngine);

      cellView.cellElement.classes.add('flash');
      new Timer(new Duration(seconds: 1), () => cellView.cellElement.classes.remove('flash'));
    });

    node.whenDone.then((_) {
      setupListenersForCell();

      cellView.cellElement.classes.add('flash');
      new Timer(new Duration(seconds: 1), () => cellView.cellElement.classes.remove('flash'));
    });
  }
}
