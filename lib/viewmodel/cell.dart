part of cuscus.viewmodel;

class CellViewModel {
  int row;
  int column;

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
  String get formula => spreadsheetEngineViewModel.stringifyFormula(cellContents, sheetViewModel.id);

  /// When the shape is changed directly, the node in the engine is replaced. For this case,
  /// we don't want to duplicate the number of listeners on the node by adding another listener on the node in the whenDone event.
  bool updatedFromDirectEdit = false;

  void commitFormulaString(String formula, {bool updatedFromDirectEdit = true}) {
    String jsonParseTree = parser.parseFormula(formula);
    Map formulaParseTree = JSON.decode(jsonParseTree);
    engine.CellContents cellContents = spreadsheetEngineViewModel.resolveSymbols(formulaParseTree, sheetViewModel.id);

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
    if (this.cellContents == null) {
      this.updatedFromDirectEdit = false;
    } else {
      this.updatedFromDirectEdit = updatedFromDirectEdit;
    }
    this.cellContents = cellContents;
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    spreadsheetEngineViewModel.setNode(cellContents, cell);
    spreadsheetEngineViewModel.updateDependencyGraph();

    // Update contents of current cell and set listeners
    setupListenersForCell();
  }

  update() {
    print ("update");
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    engine.SpreadsheetDepNode node = spreadsheetEngineViewModel.cells[cell];
    cellContents = node.value;

    updatedFromDirectEdit = false;
    setupListenersForCell();

    cellView.cellElement.classes.add('flash');
    new Timer(new Duration(seconds: 1), () => cellView.cellElement.classes.remove('flash'));
  }

  setupListenersForCell() {
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    engine.SpreadsheetDepNode node = spreadsheetEngineViewModel.cells[cell];
    cellContents = node.value;

    _text = node.computedValue.toString();

    // This is when the node has been changed due to value propagation in the engine.
    node.onChange.listen((_) {
      engine.SpreadsheetDepNode node = spreadsheetEngineViewModel.cells[cell];
      cellContents = node.value;

      _text = node.computedValue.toString();

      print('on change');
      cellView.cellElement.classes.add('flash');
      new Timer(new Duration(seconds: 1), () => cellView.cellElement.classes.remove('flash'));
    });

    // This is when the node has been edited directly, which results in a replacement in the engine.
    node.whenDone.then((_) {
      print('when done cell before if');
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
