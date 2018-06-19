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

  /// When the shape is changed directly, the node in the engine is replaced. For this case,
  /// we don't want to duplicate the number of listeners on the node by adding another listener on the node in the whenDone event.
  bool updatedFromDirectEdit = false;

  void commitFormulaString(String formula, {bool updatedFromDirectEdit = true}) {
    String jsonParseTree = parser.parseFormula(formula);
    Map formulaParseTree = JSON.decode(jsonParseTree);
    engine.CellContents cellContents = resolveSymbols(formulaParseTree, sheetViewModel.id, spreadsheetEngine);

    commitFormula(cellContents, updatedFromDirectEdit: updatedFromDirectEdit);

    // TODO fix hack
    if (sheetViewModel is GraphicsSheetViewModel) {
      GraphicsSheetViewModel sheet = sheetViewModel;
      if (!sheet.layerViewModel.shapes.containsKey(row)) {
        sheet.fillInRowWithAlreadyFilledInCells(row, [column]);
      }
    }
  }

  void commitFormula(engine.CellContents cellContents, {bool updatedFromDirectEdit = true}) {
    print ("commit formula");
    this.cellContents = cellContents;
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    addNodeToSpreadsheetEngine(cellContents, cell, spreadsheetEngine);

    // Propagate the changes in the dependency graph.
    spreadsheetEngine.depGraph.update();

    this.updatedFromDirectEdit = updatedFromDirectEdit;
    // Update contents of current cell and set listeners
    setupListenersForCell();
  }

  update() {
    print ("update");
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

    _text = node.computedValue.toString();
    _userEnteredFormula = stringifyFormula(cellContents, sheetViewModel.id, spreadsheetEngine);

    // This is when the node has been changed due to value propagation in the engine.
    node.onChange.listen((_) {
      engine.SpreadsheetDepNode node = spreadsheetEngine.cells[cell];
      cellContents = node.value;

      _text = node.computedValue.toString();
      _userEnteredFormula = stringifyFormula(cellContents, sheetViewModel.id, spreadsheetEngine);

      print('on change');
      cellView.cellElement.classes.add('flash');
      new Timer(new Duration(seconds: 1), () => cellView.cellElement.classes.remove('flash'));
    });

    // This is when the node has been edited directly, which results in a replacement in the engine.
    node.whenDone.then((_) {
      if (!updatedFromDirectEdit) {
        setupListenersForCell();
        print('when done cell');
        cellView.cellElement.classes.add('flash');
        new Timer(new Duration(seconds: 1), () => cellView.cellElement.classes.remove('flash'));
      } else {
        updatedFromDirectEdit = false;
      }
    });
  }
}
