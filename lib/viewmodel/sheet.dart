part of cuscus.viewmodel;

// An intermediate abstraction between the execution engine and the UI.
abstract class SheetViewModel extends ObjectWithId {
  int rows;
  int columns;
  String name;
  SheetbookViewModel sheetbookViewModel;
  view.SheetView sheetView;
  List<List<CellViewModel>> cells = [];

  List<String> activeColumnNames;

  SheetViewModel(this.rows, this.columns, this.name) : super() {
    sheets.add(this);
    for (int r = 0; r < rows; r++) {
      cells.add([]);
      for (int c = 0; c < columns; c++) {
        cells.last.add(new CellViewModel(r, c, this));
      }
    }
  }

  CellViewModel selectedCell;

  void deselectCell() {
    selectedCell = null;
    sheetView.selectedCell = null;

    sheetView.hideCellSelector();
  }

  void selectCellAtCoords(int row, int col) {
    selectedCell = cells[row][col];
    sheetView.selectedCell = selectedCell.cellView;
    sheetView.showCellSelector();
    cellInputFormulaBarViewModel.contents = selectedCell.formula;
  }
  void selectCellBelow(CellViewModel cell) {
    selectCellAtCoords(cell.row + 1, cell.column);
  }
  void selectCellAbove(CellViewModel cell) {
    selectCellAtCoords(math.max(0, cell.row - 1), cell.column);
  }
  void selectCellRight(CellViewModel cell) {
    selectCellAtCoords(cell.row, cell.column + 1);
  }
  void selectCellLeft(CellViewModel cell) {
    selectCellAtCoords(cell.row, math.max(0, cell.column - 1));
  }

  void fillInCellsWithCell(Map<int, List<int>> cellsToFillIn, CellViewModel sourceCell) {
    cellsToFillIn.forEach((row, columns) {
      columns.forEach((column) {
        CellViewModel cellToFillIn = cells[row][column];
        engine.CellContents cellContents = sourceCell.cellContents;
        engine.CellContents newCellContents = spreadsheetEngineViewModel.makeRelativeCellContents(
          cellContents,
          new engine.CellCoordinates(sourceCell.row, sourceCell.column, sourceCell.sheetViewModel.id),
          new engine.CellCoordinates(cellToFillIn.row, cellToFillIn.column, cellToFillIn.sheetViewModel.id));

        cellToFillIn.commitFormula(newCellContents);
        // cellToFillIn.update();
      });
    });
  }

  String toString() {
    return '$name:$id';
  }
}

class DataSheet extends SheetViewModel {
  DataSheet(rows, columns, name) : super(rows, columns, name) {
    activeColumnNames = getColumns(columns);
  }
}

class WrangleSheet extends SheetViewModel {
  WrangleSheet(rows, columns, name) : super(rows, columns, name) {
    activeColumnNames = getColumns(columns);
  }
}

abstract class GraphicsSheetViewModel extends SheetViewModel {
  LayerViewModel layerViewModel;
  view.GraphicsSheetView sheetView;

  GraphicsSheetViewModel(rows, columns, name) : super(rows, columns, name);

  bool hasMultipleOptionsForColumn(int column);
  List<String> getOptionsForColumn(int column);
  void selectOptionForColumn(int column, String option);

  selectRow(int row) => sheetView.showRowSelector(row);
  deselectRow(int row) => sheetView.hideRowSelector(row);

  updateRow(int row) {
    cells[row].forEach((CellViewModel cell) => cell.update());
  }

  void selectCellAtCoords(int row, int col) {
    super.selectCellAtCoords(row, col);
    layerViewModel.selectShapeAtIndex(row);
  }

  void deselectCell() {
    layerViewModel.deselectShape();
    super.deselectCell();
  }

  void fillInRowWithAlreadyFilledInCells(int row, List<int> alreadyFilledInCollumns) {
    print ('fillInRowWithAlreadyFilledInCells $row $alreadyFilledInCollumns');
    List<CellViewModel> firstRowOfCells = cells[0];
    List<CellViewModel> newRowOfCells = cells[row];
    newRowOfCells.where((c) => !alreadyFilledInCollumns.contains(c.column)).forEach((emptyCell) {
      int index = newRowOfCells.indexOf(emptyCell);
      CellViewModel templateCell = firstRowOfCells[index];
      engine.CellContents cellContents = firstRowOfCells[index].cellContents;
      engine.CellContents newCellContents = spreadsheetEngineViewModel.makeRelativeCellContents(
        cellContents,
        new engine.CellCoordinates(templateCell.row, templateCell.column, templateCell.sheetViewModel.id),
        new engine.CellCoordinates(emptyCell.row, emptyCell.column, emptyCell.sheetViewModel.id));

      emptyCell.commitFormula(newCellContents);
    });
    // updateRow(cell.row);

    layerViewModel.addShapeFromRow(row);
  }

  void fillInCellsWithCell(Map<int, List<int>> cellsToFillIn, CellViewModel sourceCell) {
    print (cellsToFillIn);
    super.fillInCellsWithCell(cellsToFillIn, sourceCell);
    cellsToFillIn.forEach((row, columns) {
      fillInRowWithAlreadyFilledInCells(row, columns);
    });
  }
}

class LineSheet extends GraphicsSheetViewModel {
  LineSheet(rows, name) : super(rows, linePropertyToColumnName.length, name) {
    activeColumnNames = linePropertyToColumnName.values.toList();
    columns = activeColumnNames.length;
  }

  bool hasMultipleOptionsForColumn(int column) {
    return _lineProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _lineProperties[column];
  }
  void selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }
}

class RectSheet extends GraphicsSheetViewModel {
  RectSheet(rows, name) : super(rows, rectPropertyToColumnName.length, name) {
    activeColumnNames = rectPropertyToColumnName.values.toList();
    columns = activeColumnNames.length;
  }

  bool hasMultipleOptionsForColumn(int column) {
    return _rectProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _rectProperties[column];
  }
  void selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }
}

class EllipseSheet extends GraphicsSheetViewModel {
  EllipseSheet(rows, name) : super(rows, _ellipseProperties.length, name) {
    activeColumnNames = _ellipseProperties.map((item) => item.first).toList();
    columns = activeColumnNames.length;
  }

  bool hasMultipleOptionsForColumn(int column) {
    return _ellipseProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _ellipseProperties[column];
  }
  void selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }
}

class TextSheet extends GraphicsSheetViewModel {
  TextSheet(rows, name) : super(rows, _textProperties.length, name) {
    activeColumnNames = _textProperties.map((item) => item.first).toList();
    columns = activeColumnNames.length;
  }

  bool hasMultipleOptionsForColumn(int column) {
    return _textProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _textProperties[column];
  }
  void selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }
}

// line, rect, ellipse: each row in the spreadsheet represents one element.
final List<List> _lineProperties = [
        ['Start X'],
        ['Start Y'],
        ['End X'],
        ['End Y'],
        ['Stroke Width'],
        ['Stroke Color'],
        ['Stroke Opacity'],
        ];
final List<List> _rectProperties = [
        ['Width'],
        ['Height'],
        ['Center X', 'Left', 'Right'],
        ['Center Y', 'Top', 'Bottom'],
        ['Corner Radius X'],
        ['Corner Radius Y'],
        ['Rotation'],
        ['Fill Color'],
        ['Fill Opacity'],
        ['Border Style'],
        ['Border Width'],
        ['Border Color'],
        ['Border Opacity'],
        ];
final List<List> _ellipseProperties = [
        ['Radius X'],
        ['Radius Y'],
        ['Center X', 'Left', 'Right'],
        ['Center Y', 'Top', 'Bottom'],
        ['Rotation'],
        ['Fill Color'],
        ['Fill Opacity'],
        ['Border Style'],
        ['Border Width'],
        ['Border Color'],
        ['Border Opacity'],
        ];
final List<List> _textProperties = [
        ['Content'],
        ['Alignment'],
        ['Width'],
        ['Height'],
        ['Center X', 'Left', 'Right'],
        ['Center Y', 'Top', 'Bottom'],
        ['Rotation'],
        ['Text Color'],
        ['Text Opacity'],
        ['Background Color'],
        ['Background Opacity'],
        ['Border Style'],
        ['Border Width'],
        ['Border Color'],
        ['Border Opacity'],
        ];

// path, polyline, polygon: each row represents a point in a series of points.
final List<List> _polylineProperties = [
        ['X'],
        ['Y'],
        ];
final List<List> __polylineSingleProperties = [
        ['Line Type'], // sharp/smooth (only line implemented, for curve line see https://en.wikipedia.org/wiki/Cubic_Hermite_spline#Interpolating_a_data_set)
        ['Fill Color'],
        ['Fill Opacity'],
        ['Stroke Style'],
        ['Stroke Width'],
        ['Stroke Color'],
        ['Stroke Opacity'],
        ];
final List<List> _polygonProperties = [
        ['X'],
        ['Y'],
        ];
final List<List> __polygonSingleProperties = [
        ['Fill Color'],
        ['Fill Opacity'],
        ['Stroke Style'],
        ['Stroke Width'],
        ['Stroke Color'],
        ['Stroke Opacity'],
        ];

final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

List<String> getColumns(int columns) {
  if (columns < _letters.length) {
    return _letters.getRange(0, columns).toList();
  } else {
    List<String> resultLetters = new List.from(_letters);
    _letters.forEach((String letter) {
      resultLetters.addAll(_letters.map((String l) => '$letter$l'));
      if (resultLetters.length > columns) {
        return resultLetters.getRange(0, columns).toList();
      }
    });
    throw "Too many columns.";
  }
}
