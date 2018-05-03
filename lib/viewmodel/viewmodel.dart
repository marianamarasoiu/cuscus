library cuscus.viewmodel;

import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:math' as math;

// Import the model
import 'package:cuscus/model/execution_engine/spreadsheet.dart' as engine;
import 'package:cuscus/model/formula_parser/formula_parser.dart' as parser;

// Import the view
import 'package:cuscus/view/view.dart' as view;

part 'sheet.dart';
part 'sheetbook.dart';

part 'object_id.dart';

part 'formula_parsing_utils.dart';


enum InteractionState {
  idle,
  cellSelected,
  cellEditing,
}
enum InteractionAction {
  // actions on sheets
  createNewSheet,
  selectSheet,
  renameSheet,
  deleteSheet,

  // actions on spreadsheet cells
  click,
  doubleClick,
  enter,
}

List<SheetViewModel> sheets = [];
List<SheetbookViewModel> sheetbooks = [];
// Selecting a cell
SheetViewModel activeSheet;

DivElement get _cellInputBox => querySelector('.input-box'); // TODO: rename element to #cell-input-box
DivElement get _visualisationContainer => querySelector('#vis-canvas'); // TODO: rename element to #visualisation-container
DivElement get _spreadsheetsContainer => querySelector('#sheets-container'); // TODO: rename element to #spreadsheets-container

initListeners() {
  document.onClick.listen((MouseEvent click) => command(InteractionAction.click, click));
  document.onDoubleClick.listen((MouseEvent doubleclick) => command(InteractionAction.doubleClick, doubleclick));
  _cellInputBox.onKeyDown.listen((KeyboardEvent keyEvent) {
    if (keyEvent.key == "Enter") command(InteractionAction.enter, keyEvent);
  });
}

engine.SpreadsheetEngine spreadsheetEngine = new engine.SpreadsheetEngine();

InteractionState state = InteractionState.idle;

command(InteractionAction action, var data) {
  switch (state) {
    case InteractionState.idle:
    case InteractionState.cellSelected:
      if (action == InteractionAction.click) {
        MouseEvent mouseEvent = data;
        mouseEvent.stopImmediatePropagation();
        mouseEvent.stopPropagation();
        mouseEvent.preventDefault();

        if (mouseEvent.target is TableCellElement) {
          SheetViewModel sheet = getSheetOfElement(mouseEvent.target);
          sheet.view.selectedCell = mouseEvent.target;
          if (sheet != activeSheet) {
            activeSheet?.view?.selectedCell = null;
            activeSheet = sheet;
          }
          state = InteractionState.cellSelected;
        }
        
      } else if (action == InteractionAction.doubleClick) {
        MouseEvent mouseEvent = data;
        mouseEvent.stopImmediatePropagation();
        mouseEvent.stopPropagation();
        mouseEvent.preventDefault();

        if (mouseEvent.target is TableCellElement) {
          SheetViewModel sheet = getSheetOfElement(mouseEvent.target);
          sheet.view.selectedCell = mouseEvent.target;
          if (sheet != activeSheet) {
            activeSheet?.view?.selectedCell = null;
            activeSheet = sheet;
          }
        }

        if (mouseEvent.target is TableCellElement ||
            (mouseEvent.target is DivElement && (mouseEvent.target as DivElement).classes.contains('cell-selector'))) {
          SheetViewModel sheet = getSheetOfElement(mouseEvent.target);
          // _cellInputBox.style.height = '${sheet.view.selectedCell.client.height - 2}px';
          // _cellInputBox.style.width = '${sheet.view.selectedCell.client.width - 4}px';
          _cellInputBox.style.minHeight = '${sheet.view.selectedCell.client.height - 2}px';
          _cellInputBox.style.minWidth = '${sheet.view.selectedCell.client.width - 4}px';
          _cellInputBox.style.maxHeight = '200px'; // TODO: these should come from the distance between the selected cell and bottom and right margin.
          _cellInputBox.style.maxWidth = '500px';
          _cellInputBox.style.visibility = 'visible';
          _cellInputBox.style.top = '${sheet.view.selectedCell.getBoundingClientRect().top - 1}px';
          _cellInputBox.style.left = '${sheet.view.selectedCell.getBoundingClientRect().left - 1}px';
          _cellInputBox.querySelector('.cell-input')
            ..text = sheet.view.selectedCell.text
            ..focus();
          // window.requestAnimationFrame((_) => _cellInputBox.focus());
          state = InteractionState.cellEditing;
        }
      }
      break;
    case InteractionState.cellEditing:
      if (action == InteractionAction.enter) {
        KeyboardEvent keyEvent = data;
        keyEvent.stopImmediatePropagation();
        keyEvent.stopPropagation();
        keyEvent.preventDefault();

        engine.CellCoordinates cell = new engine.CellCoordinates(
            activeSheet.view.selectedCellRow, 
            activeSheet.view.selectedCellColumn,
            activeSheet.view.sheetViewModel.id);
        String formula = parser.parseFormula(_cellInputBox.text.trim());
        print(formula);
        Map formulaParseTree = JSON.decode(formula);
        var elementsResolvedTree = resolveSymbols(formulaParseTree, activeSheet.id, spreadsheetEngine);
        addNodeToSpreadsheetEngine(elementsResolvedTree, cell, spreadsheetEngine);
        

        // Get the list of cells to update
        List<engine.SpreadsheetDep> dirtyNodes = spreadsheetEngine.depGraph.dirtyNodes.toList();
        List<engine.CellCoordinates> cellsToUpdate = [];
        spreadsheetEngine.cells.forEach((cell, dep) {
          if (dirtyNodes.contains(dep)) cellsToUpdate.add(cell);
        });

        // Propagate the changes in the dependency graph.        
        print(spreadsheetEngine);
        spreadsheetEngine.depGraph.update();
        print(spreadsheetEngine);

        // Update the cells in the interface
        cellsToUpdate.forEach((cell) {
          SheetViewModel sheet = sheets.singleWhere((sheet) => sheet.id == cell.sheetId);
          sheet.view.dataElements[cell.row][cell.col].text = '${spreadsheetEngine.cells[cell].computedValue}';
        });

        activeSheet.view.selectedCell.text = spreadsheetEngine.cells[cell].computedValue.toString();
        _cellInputBox.style.visibility = 'hidden';
        state = InteractionState.cellSelected;
      }
      break;
  }
}

SheetViewModel getSheetOfElement(Element cell) {
  DivElement sheetContainer = getParentOfClass(cell, 'sheet');
  int sheetId = int.parse(sheetContainer.getAttribute('data-sheet-id'));
  return sheets.singleWhere((sheet) => sheet.id == sheetId);
}


Element getParentOfType(Element e, Type parentType) {
  Element parent = e.parent;
  while (parent != null) {
    if (parent.runtimeType == parentType) {
      return parent;
    } else {
      parent = parent.parent;
    }
  }
  return null; // no parent of the given type.
}

Element getParentOfClass(Element e, String className) {
  Element parent = e.parent;
  while (parent != null) {
    if (parent.classes.contains(className)) {
      return parent;
    } else {
      parent = parent.parent;
    }
  }
  return null; // no parent with the given class.
}
