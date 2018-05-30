library cuscus.viewmodel;

import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:math' as math;

// Import the model
import 'package:cuscus/model/execution_engine/spreadsheet.dart' as engine;
import 'package:cuscus/model/formula_parser/formula_parser.dart' as parser;

// Import the view
import 'package:cuscus/view/view.dart' as view;
import 'package:cuscus/view/box_layout.dart' as box_layout;

part 'sheet.dart';
part 'sheetbook.dart';
part 'graphics_editor.dart';

part 'object_id.dart';

part 'formula_parsing_utils.dart';


enum InteractionState { // Rename to uiState
  idle,
  readyToDraw,
  drawing,
  cellSelected,
  cellEditing,
}
enum InteractionAction { // Rename to uiAction
  // actions on the visualisation
  clickInToolPanel,
  mouseDownOnCanvas,
  mouseUpOnCanvas,

  // actions on sheets
  createNewSheet,
  selectSheet,
  renameSheet,
  deleteSheet,

  // actions on spreadsheet cells
  click,
  doubleClick,
  enter,
  escape,
  shift,
  alt,
  control,
  meta,
  backspace,
  capsLock,
  tab,
  arrowRight,
  arrowLeft,
  arrowUp,
  arrowDown,
  otherKey,
}

enum ShapeType {
  rect,
  ellipse,
  triangle,
  line,
  curve,
  text,
}

List<SheetViewModel> sheets = [];
List<SheetbookViewModel> sheetbooks = [];
engine.SpreadsheetEngine spreadsheetEngine = new engine.SpreadsheetEngine();
GraphicsEditorViewModel graphicsEditorViewModel;

DivElement get _mainContainer => querySelector('#main-container'); // TODO: rename element to #main-container
DivElement get _spreadsheetsContainer => querySelector('#sheets-container'); // TODO: rename element to #spreadsheets-container
DivElement get _graphicsEditorContainer => querySelector('#vis-canvas'); // TODO: rename element to #graphics-editor-container
DivElement get _cellInputBox => querySelector('.input-box'); // TODO: rename element to #cell-input-box

init() {
  // Init layout elements.
  new box_layout.Box(_mainContainer);
  new box_layout.Box(_spreadsheetsContainer);

  // Create the incoming data spreadsheet
  {
    SheetbookViewModel sheetbook = new SheetbookViewModel();
    sheetbooks.add(sheetbook);
    sheetbook.createView(_spreadsheetsContainer.querySelector('#left-sheet'));
    sheetbook.addSheet('DataSheet');
  }

  // Create the data wrangling spreadsheet
  {
    SheetbookViewModel sheetbook = new SheetbookViewModel();
    sheetbooks.add(sheetbook);
    sheetbook.createView(_spreadsheetsContainer.querySelector('#middle-sheet'));
    sheetbook.addSheet('WrangleSheet');
  }

  // Create the visualisation spreadsheet and initialise the graphics editor with it
  {
    SheetbookViewModel sheetbook = new SheetbookViewModel();
    sheetbooks.add(sheetbook);
    sheetbook.createView(_spreadsheetsContainer.querySelector('#right-sheet'));

    graphicsEditorViewModel = new GraphicsEditorViewModel(sheetbook);
    graphicsEditorViewModel.createView();
  }

  // Init listeners
  document.onClick.listen((MouseEvent click) => command(InteractionAction.click, click));
  document.onDoubleClick.listen((MouseEvent doubleclick) => command(InteractionAction.doubleClick, doubleclick));
  document.onKeyDown.listen((KeyboardEvent keyEvent) {
    if (keyEvent.key == "Enter") {
      command(InteractionAction.enter, keyEvent);
    } else if (keyEvent.key == "Escape") {
      command(InteractionAction.escape, keyEvent);
    } else if (keyEvent.key == "Shift") {
      command(InteractionAction.shift, keyEvent);
    } else if (keyEvent.key == "Alt") {
      command(InteractionAction.alt, keyEvent);
    } else if (keyEvent.key == "Control") {
      command(InteractionAction.control, keyEvent);
    } else if (keyEvent.key == "Meta") {
      command(InteractionAction.meta, keyEvent);
    } else if (keyEvent.key == "Backspace") {
      command(InteractionAction.backspace, keyEvent);
    } else if (keyEvent.key == "CapsLock") {
      command(InteractionAction.capsLock, keyEvent);
    } else if (keyEvent.key == "Tab") {
      command(InteractionAction.tab, keyEvent);
    } else if (keyEvent.key == "ArrowRight") {
      command(InteractionAction.arrowRight, keyEvent);
    } else if (keyEvent.key == "ArrowLeft") {
      command(InteractionAction.arrowLeft, keyEvent);
    } else if (keyEvent.key == "ArrowUp") {
      command(InteractionAction.arrowUp, keyEvent);
    } else if (keyEvent.key == "ArrowDown") {
      command(InteractionAction.arrowDown, keyEvent);
    } else {
      command(InteractionAction.otherKey, keyEvent);
    }
  });
}

InteractionState _state = InteractionState.idle;
InteractionState get state => _state;
set state(InteractionState newState) {
  print('New state: $newState');
  _state = newState;
}

// State data
// For selecting a cell
SheetViewModel activeSheet;
// For drawing
ShapeType shapeToDraw;

command(InteractionAction action, var data) {
  switch (state) {
    /*
     * State: idle
     */
    case InteractionState.idle:
      switch (action) {
        case InteractionAction.clickInToolPanel:
          shapeToDraw = data;
          graphicsEditorViewModel.graphicsEditorView.selectShapeButton(shapeToDraw);
          state = InteractionState.readyToDraw;
          break;
        
        default:
          break;
      }
      break;

    /*
     * State: readyToDraw
     */
    case InteractionState.readyToDraw:
      switch (action) {
        case InteractionAction.clickInToolPanel:
          shapeToDraw = data;
          graphicsEditorViewModel.graphicsEditorView.deselectAllShapeButtons();
          graphicsEditorViewModel.graphicsEditorView.selectShapeButton(shapeToDraw);
          state = InteractionState.readyToDraw;
          break;
        case InteractionAction.mouseDownOnCanvas:
          MouseEvent mouseDown = data;
          stopDefaultBehaviour(mouseDown);
          graphicsEditorViewModel.graphicsEditorView.startDrawing(mouseDown);
          state = InteractionState.drawing;
          break;
        default:
          break;
      }
      break;

    /*
     * State: drawing
     */
    case InteractionState.drawing:
      switch (action) {
        case InteractionAction.mouseUpOnCanvas:
          // MouseEvent mouseUp = data;
          // stopDefaultBehaviour(mouseUp);
          // graphicsEditorViewModel.graphicsEditorView.stopDrawing(mouseUp);
          // commit change to the rest of the application
          state = InteractionState.idle; // ??
          break;
        default:
          break;
      }
      break;

    /*
     * State: cellSelected
     */
    case InteractionState.cellSelected:
      switch (action) {
        case InteractionAction.click:
          MouseEvent mouseEvent = data;
          stopDefaultBehaviour(mouseEvent);

          if (mouseEvent.target is TableCellElement) {
            SheetViewModel sheet = getSheetOfElement(mouseEvent.target);
            sheet.view.selectedCell = mouseEvent.target;
            if (sheet != activeSheet) {
              activeSheet?.view?.selectedCell = null;
              activeSheet = sheet;
            }
            state = InteractionState.cellSelected;
          }
          break;
        case InteractionAction.doubleClick:
          MouseEvent mouseEvent = data;
          stopDefaultBehaviour(mouseEvent);

          EventTarget eventTarget = mouseEvent.target;
          if (eventTarget is TableCellElement ||
            (eventTarget is DivElement && eventTarget.classes.contains('cell-selector'))) {
            _editCell(eventTarget);
            state = InteractionState.cellEditing;
          }
          break;
        case InteractionAction.enter:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          _editCell(activeSheet.view.selectedCell);
          state = InteractionState.cellEditing;
          break;
        case InteractionAction.backspace:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          _commitFormulaToSelectedCell('');
          break;
        case InteractionAction.arrowRight:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          activeSheet.view.selectCellRight(activeSheet.view.selectedCell);
          state = InteractionState.cellSelected;
          break;
        case InteractionAction.arrowLeft:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          activeSheet.view.selectCellLeft(activeSheet.view.selectedCell);
          state = InteractionState.cellSelected;
          break;
        case InteractionAction.arrowUp:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          activeSheet.view.selectCellAbove(activeSheet.view.selectedCell);
          state = InteractionState.cellSelected;
          break;
        case InteractionAction.arrowDown:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          activeSheet.view.selectCellBelow(activeSheet.view.selectedCell);
          state = InteractionState.cellSelected;
          break;
        case InteractionAction.otherKey:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          _editCell(activeSheet.view.selectedCell);
          state = InteractionState.cellEditing;

          _cellInputBox.querySelector('.cell-input').text = keyboardEvent.key;
          window.getSelection().collapse(_cellInputBox.querySelector('.cell-input'), 1);
            
          break;
        default:
          break;
      }
      break;

    /*
     * State: cellEditing
     */
    case InteractionState.cellEditing:
      switch (action) {
        case InteractionAction.enter:
          KeyboardEvent keyEvent = data;
          stopDefaultBehaviour(keyEvent);

          _commitFormulaToSelectedCell(_cellInputBox.text.trim());

          activeSheet.view.selectCellBelow(activeSheet.view.selectedCell);
          state = InteractionState.cellSelected;
          break;
        case InteractionAction.arrowRight:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          _commitFormulaToSelectedCell(_cellInputBox.text.trim());

          activeSheet.view.selectCellRight(activeSheet.view.selectedCell);
          state = InteractionState.cellSelected;
          break;
        case InteractionAction.arrowLeft:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          _commitFormulaToSelectedCell(_cellInputBox.text.trim());

          activeSheet.view.selectCellLeft(activeSheet.view.selectedCell);
          state = InteractionState.cellSelected;
          break;
        case InteractionAction.arrowUp:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          _commitFormulaToSelectedCell(_cellInputBox.text.trim());

          activeSheet.view.selectCellAbove(activeSheet.view.selectedCell);
          state = InteractionState.cellSelected;
          break;
        case InteractionAction.arrowDown:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          _commitFormulaToSelectedCell(_cellInputBox.text.trim());

          activeSheet.view.selectCellBelow(activeSheet.view.selectedCell);
          state = InteractionState.cellSelected;
          break;
        case InteractionAction.click:
          MouseEvent mouseEvent = data;
          stopDefaultBehaviour(mouseEvent);
          
          EventTarget eventTarget = mouseEvent.target;
          if (eventTarget is DivElement && eventTarget.classes.contains('cell-input')) {
              // Clicking inside the cell being edited => ignore
          } else {
            _commitFormulaToSelectedCell(_cellInputBox.text.trim());
            
            state = InteractionState.cellSelected;
            
            // Process the click
            command(InteractionAction.click, data);
          }
          break;
        default:
          break;
      }
      break;
  }
}

stopDefaultBehaviour(Event event) { // Move to a common utils file
  event.stopImmediatePropagation();
  event.stopPropagation();
  event.preventDefault();
}

_editCell(EventTarget eventTarget) {
  if (eventTarget is TableCellElement) {
    SheetViewModel sheet = getSheetOfElement(eventTarget);
    sheet.view.selectedCell = eventTarget;
    if (sheet != activeSheet) {
      activeSheet?.view?.selectedCell = null;
      activeSheet = sheet;
    }
  }

  SheetViewModel sheet = getSheetOfElement(eventTarget);
  _cellInputBox.style.minHeight = '${sheet.view.selectedCell.client._height - 2}px';
  _cellInputBox.style.minWidth = '${sheet.view.selectedCell.client._width - 4}px';
  _cellInputBox.style.maxHeight = '200px'; // TODO: these should come from the distance between the selected cell and bottom and right margin.
  _cellInputBox.style.maxWidth = '500px';
  _cellInputBox.style.visibility = 'visible';
  _cellInputBox.style.top = '${sheet.view.selectedCell.getBoundingClientRect().top - 1}px';
  _cellInputBox.style.left = '${sheet.view.selectedCell.getBoundingClientRect().left - 1}px';
  _cellInputBox.querySelector('.cell-input')
    ..text = sheet.view.selectedCell.text
    ..focus();
}

bool _commitFormulaToSelectedCell(String formula) {
  engine.CellCoordinates cell = new engine.CellCoordinates(
      activeSheet.view.selectedCellRow, 
      activeSheet.view.selectedCellColumn,
      activeSheet.view.sheetViewModel.id);
  String jsonParseTree = parser.parseFormula(formula);
  Map formulaParseTree = JSON.decode(jsonParseTree);
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

  // Update contents of current cell
  activeSheet.view.selectedCell.text = spreadsheetEngine.cells[cell].computedValue.toString();
  
  // Hide the cell editing box
  _cellInputBox.style.visibility = 'hidden';
  return true;
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
