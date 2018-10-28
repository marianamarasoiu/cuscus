part of cuscus.viewmodel;

class CellViewModel {
  static CellViewModel _selectedCell;
  static CellViewModel get selectedCell => _selectedCell;
  static void clear() => _selectedCell = null;

  int row;
  int column;

  engine.CellContents cellContents = null;
  String _value = '';

  SheetViewModel sheetViewModel;
  view.CellView cellView;

  CellViewModel(this.row, this.column, this.sheetViewModel) {
    cellView = new view.CellView(this);
  }

  set _text(String value) {
    _value = value;
    cellView.text = value;
  }

  String get value => _value;
  String get formula => SpreadsheetEngineViewModel.spreadsheet.stringifyFormula(cellContents, sheetViewModel.id);

  /// When the shape is changed directly, the node in the engine is replaced. For this case,
  /// we don't want to duplicate the number of listeners on the node by adding another listener on the node in the whenDone event.
  bool updatedFromDirectEdit = false;

  void setContentsString(String formula) {
    String jsonParseTree = parser.parseFormula(formula);
    Map formulaParseTree = jsonDecode(jsonParseTree);

    setContents(SpreadsheetEngineViewModel.spreadsheet.resolveSymbols(formulaParseTree, sheetViewModel.id));

    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];

    node.onChange.listen((_) {
      engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];
      cellContents = node.value;

      _text = node.computedValue.toString();
    });
  }

  void setContents(engine.CellContents cellContents) {
    this.cellContents = cellContents;
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    SpreadsheetEngineViewModel.spreadsheet.setNode(cellContents, cell);
  }

  void commitContents() {
    SpreadsheetEngineViewModel.spreadsheet.updateDependencyGraph();
  }

  void commitFormulaString(String formula, {bool updatedFromDirectEdit = true}) {
    String jsonParseTree = parser.parseFormula(formula);
    Map formulaParseTree = jsonDecode(jsonParseTree);
    engine.CellContents cellContents = SpreadsheetEngineViewModel.spreadsheet.resolveSymbols(formulaParseTree, sheetViewModel.id);

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
    SpreadsheetEngineViewModel.spreadsheet.setNode(cellContents, cell);
    SpreadsheetEngineViewModel.spreadsheet.updateDependencyGraph();

    // Update contents of current cell and set listeners
    setupListenersForCell();
  }

  update() {
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];
    cellContents = node.value;

    updatedFromDirectEdit = false;
    setupListenersForCell();

    cellView.uiElement.classes.add('flash');
    new Timer(new Duration(seconds: 1), () => cellView.uiElement.classes.remove('flash'));
  }

  setupListenersForCell() {
    engine.CellCoordinates cell = new engine.CellCoordinates(row, column, sheetViewModel.id);
    engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];
    cellContents = node.value;

    _text = node.computedValue.toString();

    // This is when the node has been changed due to value propagation in the engine.
    node.onChange.listen((_) {
      engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];
      cellContents = node.value;

      _text = node.computedValue.toString();

      print('on change');
      cellView.uiElement.classes.add('flash');
      new Timer(new Duration(seconds: 1), () => cellView.uiElement.classes.remove('flash'));
    });

    // This is when the node has been edited directly, which results in a replacement in the engine.
    node.whenDone.then((_) {
      print('when done cell before if');
      if (!updatedFromDirectEdit) {
        setupListenersForCell();
        print('when done cell');
        cellView.uiElement.classes.add('flash');
        new Timer(new Duration(seconds: 1), () => cellView.uiElement.classes.remove('flash'));
      } else {
        updatedFromDirectEdit = false;
      }
    });
  }


  /**
   * Cell selection
   */
  void select() {
    if (_selectedCell == this) return;
    _selectedCell?.deselect();
    _selectedCell = this;
    sheetViewModel.sheetView.selectedCell = this.cellView;
    sheetViewModel.sheetView.showCellSelector();

    if (sheetViewModel is GraphicsSheetViewModel) {
      (sheetViewModel as GraphicsSheetViewModel).layerViewModel.shapes[row]?.select();
    }
  }
  void deselect() {
    _selectedCell = null;
    sheetViewModel.sheetView.selectedCell = null;
    sheetViewModel.sheetView.hideCellSelector();

    if (sheetViewModel is GraphicsSheetViewModel) {
      (sheetViewModel as GraphicsSheetViewModel).layerViewModel.shapes[row]?.deselect();
    }
  }

  void selectCellBelow() {
    sheetViewModel.cells[math.min(sheetViewModel.cells.length - 1, row + 1)][column].select();
  }
  void selectCellAbove() {
    sheetViewModel.cells[math.max(0, row - 1)][column].select();
  }
  void selectCellRight() {
    sheetViewModel.cells[row][math.min(sheetViewModel.cells[0].length - 1, column + 1)].select();
  }
  void selectCellLeft() {
    sheetViewModel.cells[row][math.max(0, column - 1)].select();
  }
}
