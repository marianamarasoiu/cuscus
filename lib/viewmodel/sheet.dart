part of cuscus.viewmodel;

const int _defaultRowCount = 100;
const int _defaultColumnCount = 15;

// An intermediate abstraction between the execution engine and the UI.
abstract class SheetViewModel extends ObjectWithId {
  static List<SheetViewModel> sheets = [];
  static int _sheetNumber = 1;
  static get _sheetCounter => _sheetNumber++;
  static SheetViewModel sheetWithId(int id) => sheets.singleWhere((sheet) => sheet.id == id);
  static SheetViewModel sheetWithName(String name) => sheets.singleWhere((sheet) => sheet.name == name);
  // State data for the active sheet
  static SheetViewModel _activeSheet;
  static SheetViewModel get activeSheet => _activeSheet;

  static void clear() {
    sheets.clear();
    _sheetNumber =
    _activeSheet = null;
  }

  int get rows => cells.length;
  int get columns => activeColumnNames.length;
  String name;
  SheetbookViewModel sheetbook;
  view.SheetView sheetView;
  List<List<CellViewModel>> cells;

  List<String> activeColumnNames;

  SheetViewModel._(this.sheetbook, [int id]) : super(id);
  factory SheetViewModel(SheetbookViewModel sheetbook, [GraphicMarkType type]) {
    SheetViewModel sheet;
    switch (type) {
      case GraphicMarkType.line:
        sheet = new LineSheetViewModel(sheetbook, 'Line${_sheetCounter}', _defaultRowCount); // Rows and columns should come in by default, no need to pass them to the constructor. Loading from a .cus file or from a .csv file should add rows automatically
        break;
      case GraphicMarkType.rect:
        sheet = new RectSheetViewModel(sheetbook, 'Rect${_sheetCounter}', _defaultRowCount);
        break;
      case GraphicMarkType.ellipse:
        sheet = new EllipseSheetViewModel(sheetbook, 'Ellipse${_sheetCounter}', _defaultRowCount);
        break;
      case GraphicMarkType.text:
        sheet = new TextSheetViewModel(sheetbook, 'Text${_sheetCounter}', _defaultRowCount);
        break;
      default:
        sheet = new DataSheet(sheetbook, 'Data${_sheetCounter}', _defaultRowCount, _defaultColumnCount);
        break;
    }
    sheets.add(sheet);

    if (sheet is GraphicsSheetViewModel) {
      LayerViewModel layerViewModel = new LayerViewModel(sheetbook.layerbook, type);
      layerViewModel.graphicsSheetViewModel = sheet;
      sheet.layerViewModel = layerViewModel;
    }

    return sheet;
  }

  factory SheetViewModel.load(sheetInfo, SheetbookViewModel sheetbook) {
    SheetViewModel sheet;

    // Set the name if needed and throw an error if it's not unique
    GraphicMarkType type = null;
    if (sheetInfo.containsKey('type')) {
      type = getGraphicMarkType(sheetInfo['type']);
    }
    String name = sheetInfo['name'];
    if (name != null) {
      if (sheets.where((sheet) => sheet.name == name).isNotEmpty) {
        throw "Cannot add sheet with the same name as existing sheet: $name";
      }
    } else {
      name = '${type}_${_sheetCounter}';
    }

    switch (type) {
      case GraphicMarkType.line:
        sheet = new LineSheetViewModel(sheetbook, name, sheetInfo['row-count'], sheetInfo['sheet-id']);
        break;
      case GraphicMarkType.rect:
        sheet = new RectSheetViewModel(sheetbook, name, sheetInfo['row-count'], sheetInfo['sheet-id']);
        break;
      case GraphicMarkType.ellipse:
        sheet = new EllipseSheetViewModel(sheetbook, name, sheetInfo['row-count'], sheetInfo['sheet-id']);
        break;
      case GraphicMarkType.text:
        sheet = new TextSheetViewModel(sheetbook, name, sheetInfo['row-count'], sheetInfo['sheet-id']);
        break;
      default:
        sheet = new DataSheet(sheetbook, name, sheetInfo['row-count'], sheetInfo['column-count'], sheetInfo['sheet-id']);
        break;
    }
    sheets.add(sheet);
    for (Map cell in sheetInfo['cells']) {
      sheet.cells[cell['row']][cell['column']].setContentsString(cell['formula']);
    }

    if (sheet is GraphicsSheetViewModel) {
      LayerViewModel layerViewModel = new LayerViewModel(sheetbook.layerbook, GraphicMarkType.line);
      layerViewModel.graphicsSheetViewModel = sheet;
      sheet.layerViewModel = layerViewModel;
      layerViewModel.update();
    }

    return sheet;
  }

  _initCells(int rowCount, int columnCount) {
    cells = <List<CellViewModel>>[];
    for (int r = 0; r < rowCount; r++) {
      cells.add(<CellViewModel>[]);
      for (int c = 0; c < columnCount; c++) {
        cells.last.add(new CellViewModel(r, c, this));
      }
    }
  }

  void fillInCellsWithCell(Map<int, List<int>> cellsToFillIn, CellViewModel sourceCell) {
    cellsToFillIn.forEach((row, columns) {
      columns.forEach((column) {
        CellViewModel cellToFillIn = cells[row][column];
        engine.CellContents cellContents = sourceCell.cellContents;
        engine.CellContents newCellContents = SpreadsheetEngineViewModel.spreadsheet.makeRelativeCellContents(
          cellContents,
          new engine.CellCoordinates(sourceCell.row, sourceCell.column, sourceCell.sheetViewModel.id),
          new engine.CellCoordinates(cellToFillIn.row, cellToFillIn.column, cellToFillIn.sheetViewModel.id));

        cellToFillIn.setContents(newCellContents);
        cellToFillIn.commitContents();
        // cellToFillIn.update();
      });
    });
  }

  String toString() {
    return '$name:$id';
  }

  Map save() {
    Map sheetMap = {
      "sheet-id": id,
      "name": name,
      "row-count": rows,
      "column-count": columns,
      "cells": []
    };
    for (var row in cells) {
      for (var cell in row) {
        if (cell.cellContents != null) {
          sheetMap["cells"].add({
            'row': cell.row,
            'column': cell.column,
            'formula': cell.formula
          });
        }
      }
    }
    return sheetMap;
  }

  void focus() {
    if (activeSheet == this) return;
    _activeSheet?.blur();
    _activeSheet = this;
    sheetbook.sheetbookView.selectedSheet = sheetView;
    sheetbook.sheetbookView.focusOnSelectedSheet();
    cells[0][0].select();
  }

  void blur() {
    _activeSheet = null;
  }
}

class DataSheet extends SheetViewModel {
  DataSheet(SheetbookViewModel sheetbook, String name, int rowCount, int columnCount, [int id]) : super._(sheetbook, id) {
    this.name = name;
    activeColumnNames = generateColumnNameLetters(columnCount);
    _initCells(rowCount, activeColumnNames.length);

    sheetView = new view.SheetView(this);
  }

  Map save() => super.save();
}

abstract class GraphicsSheetViewModel extends SheetViewModel {
  LayerViewModel layerViewModel;

  GraphicsSheetViewModel._(SheetbookViewModel sheetbook, [int id]) : super._(sheetbook, id);

  bool hasMultipleOptionsForColumn(int column);
  List<String> getOptionsForColumn(int column);
  void selectOptionForColumn(int column, String option);

  selectRow(int row) => (sheetView as view.GraphicsSheetView).showRowSelector(row);
  deselectRow(int row) => (sheetView as view.GraphicsSheetView).hideRowSelector(row);

  updateRow(int row) {
    cells[row].forEach((CellViewModel cell) => cell.update());
  }

  void fillInRowWithAlreadyFilledInCells(int row, List<int> alreadyFilledInCollumns) {
    print ('fillInRowWithAlreadyFilledInCells $row $alreadyFilledInCollumns');
    List<CellViewModel> firstRowOfCells = cells[0];
    List<CellViewModel> newRowOfCells = cells[row];
    newRowOfCells.where((c) => !alreadyFilledInCollumns.contains(c.column)).forEach((emptyCell) {
      int index = newRowOfCells.indexOf(emptyCell);
      CellViewModel templateCell = firstRowOfCells[index];
      engine.CellContents cellContents = firstRowOfCells[index].cellContents;
      engine.CellContents newCellContents = SpreadsheetEngineViewModel.spreadsheet.makeRelativeCellContents(
        cellContents,
        new engine.CellCoordinates(templateCell.row, templateCell.column, templateCell.sheetViewModel.id),
        new engine.CellCoordinates(emptyCell.row, emptyCell.column, emptyCell.sheetViewModel.id));

      emptyCell.commitFormula(newCellContents);
    });
    // updateRow(cell.row);

    layerViewModel.addShapeFromRow(row);
  }

  void fillInCellsWithCell(Map<int, List<int>> cellsToFillIn, CellViewModel sourceCell) {
    cells[sourceCell.row].forEach((cell) {
      Map<int, List<int>> newCellsToFillIn = {};
      cellsToFillIn.forEach((row, columns) => newCellsToFillIn[row] = [cell.column]);
      super.fillInCellsWithCell(newCellsToFillIn, cell);
    });
    cellsToFillIn.forEach((row, _) => layerViewModel.addShapeFromRow(row));
  }
}

class LineSheetViewModel extends GraphicsSheetViewModel {
  LineSheetViewModel(SheetbookViewModel sheetbook, String name, int rowCount, [int id]) : super._(sheetbook, id) {
    this.name = name;
    activeColumnNames = linePropertyToColumnName.values.toList();
    _initCells(rowCount, activeColumnNames.length);

    sheetView = new view.GraphicsSheetView(this);
  }

  List _lineProperties;
  bool hasMultipleOptionsForColumn(int column) {
    return _lineProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _lineProperties[column];
  }
  void selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }

  Map save() => super.save()..putIfAbsent("type", () => GraphicMarkType.line.toString());
}

class RectSheetViewModel extends GraphicsSheetViewModel {
  RectSheetViewModel(SheetbookViewModel sheetbook, String name, int rowCount, [int id]) : super._(sheetbook, id) {
    this.name = name;
    activeColumnNames = rectPropertyToColumnName.values.toList();
    _initCells(rowCount, activeColumnNames.length);

    sheetView = new view.GraphicsSheetView(this);
  }

  List _rectProperties;
  bool hasMultipleOptionsForColumn(int column) {
    return _rectProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _rectProperties[column];
  }
  void selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }

  Map save() => super.save()..putIfAbsent("type", () => GraphicMarkType.rect.toString());
}

class EllipseSheetViewModel extends GraphicsSheetViewModel {
  EllipseSheetViewModel(SheetbookViewModel sheetbook, String name, int rowCount, [int id]) : super._(sheetbook, id) {
    this.name = name;
    activeColumnNames = ellipsePropertyToColumnName.values.toList();
    _initCells(rowCount, activeColumnNames.length);

    sheetView = new view.GraphicsSheetView(this);
  }

  List _ellipseProperties;
  bool hasMultipleOptionsForColumn(int column) {
    return _ellipseProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _ellipseProperties[column];
  }
  void selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }

  Map save() => super.save()..putIfAbsent("type", () => GraphicMarkType.ellipse.toString());
}

class TextSheetViewModel extends GraphicsSheetViewModel {
  TextSheetViewModel(SheetbookViewModel sheetbook, String name, int rowCount, [int id]) : super._(sheetbook, id) {
    this.name = name;
    activeColumnNames = textPropertyToColumnName.values.toList();
    _initCells(rowCount, activeColumnNames.length);

    sheetView = new view.GraphicsSheetView(this);
  }

  List _textProperties;
  bool hasMultipleOptionsForColumn(int column) {
    return _textProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _textProperties[column];
  }
  void selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }

  Map save() => super.save()..putIfAbsent("type", () => GraphicMarkType.text.toString());
}

final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

List<String> generateColumnNameLetters(int columnCount) {
  if (columnCount <= _letters.length) {
    return _letters.getRange(0, columnCount).toList();
  } else {
    List<String> resultLetters = new List.from(_letters);
    _letters.forEach((String firstLetter) {
      resultLetters.addAll(_letters.map((String secondLetter) => '$firstLetter$secondLetter'));
      if (resultLetters.length > columnCount) {
        return resultLetters.getRange(0, columnCount).toList();
      }
    });
    throw "Too many columns requested, max is ${resultLetters.length}";
  }
}
