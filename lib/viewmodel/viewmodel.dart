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

part 'cell.dart';
part 'sheet.dart';
part 'sheetbook.dart';
part 'cell_input_box.dart';

part 'graphics_editor.dart';

part 'object_id.dart';

part 'formula_parsing_utils.dart';


enum InteractionState { // Rename to uiState
  idle,
  readyToDraw,
  drawing,
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

enum DrawingTool {
  selectionTool,
  rectangleTool,
  ellipseTool,
  lineTool,
  curveTool,
  textTool,
}

List<SheetViewModel> sheets = [];
List<SheetbookViewModel> sheetbooks = [];
engine.SpreadsheetEngine spreadsheetEngine = new engine.SpreadsheetEngine();
CellInputBoxViewModel cellInputBoxViewModel = new CellInputBoxViewModel();
GraphicsEditorViewModel graphicsEditorViewModel;

DivElement get _mainContainer => querySelector('#main-container'); // TODO: rename element to #main-container
DivElement get _spreadsheetsContainer => querySelector('#sheets-container'); // TODO: rename element to #spreadsheets-container
DivElement get _graphicsEditorContainer => querySelector('#vis-canvas'); // TODO: rename element to #graphics-editor-container

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
DrawingTool selectedDrawingTool;

init() {
  // Init layout elements.
  new box_layout.Box(_mainContainer);
  new box_layout.Box(_spreadsheetsContainer);

  // Create the incoming data spreadsheet
  {
    SheetbookViewModel sheetbook = new SheetbookViewModel();
    sheetbooks.add(sheetbook);
    sheetbook.createView(_spreadsheetsContainer.querySelector('#left-sheet'));
    activeSheet = sheetbook.addSheet('DataSheet');
    activeSheet.selectCellAtCoords(0, 0);
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
    selectedDrawingTool = DrawingTool.selectionTool;
    graphicsEditorViewModel.graphicsEditorView.selectDrawingTool(selectedDrawingTool);
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

command(InteractionAction action, var data) {
  switch (state) {
    /*
     * State: idle
     */
    case InteractionState.idle:
      switch (action) {
        case InteractionAction.clickInToolPanel:
          selectedDrawingTool = data;
          graphicsEditorViewModel.graphicsEditorView.selectDrawingTool(selectedDrawingTool);
          if (selectedDrawingTool == DrawingTool.selectionTool) {
            state = InteractionState.idle;
          } else {
            state = InteractionState.readyToDraw;
          }
          break;

        case InteractionAction.click:
          MouseEvent mouseEvent = data;
          stopDefaultBehaviour(mouseEvent);

          if (mouseEvent.target is TableCellElement) {
            TableCellElement cellElement = mouseEvent.target;
            SheetViewModel sheet = getSheetOfElement(cellElement);
            if (cellElement.attributes.containsKey('data-row') && cellElement.attributes.containsKey('data-col')) {
              int row = int.parse(cellElement.attributes['data-row']);
              int col = int.parse(cellElement.attributes['data-col']);
              sheet.selectCellAtCoords(row, col);
              if (sheet != activeSheet) {
                activeSheet.deselectCell();
                activeSheet = sheet;
              }
            } else {
              // TODO: implement column and row selection
            }
            state = InteractionState.idle;
          }
          break;

        case InteractionAction.doubleClick:
          MouseEvent mouseEvent = data;
          stopDefaultBehaviour(mouseEvent);

          EventTarget eventTarget = mouseEvent.target;
          if (eventTarget is TableCellElement ||
            (eventTarget is DivElement && eventTarget.classes.contains('cell-selector'))) {
            cellInputBoxViewModel.show(activeSheet.selectedCell);
            state = InteractionState.cellEditing;
          }
          break;

        case InteractionAction.enter:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);
          cellInputBoxViewModel.show(activeSheet.selectedCell);
          state = InteractionState.cellEditing;
          break;

        case InteractionAction.backspace:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);
          activeSheet.selectedCell.commitFormula('');
          break;

        case InteractionAction.arrowRight:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);
          activeSheet.selectCellRight(activeSheet.selectedCell);
          break;

        case InteractionAction.arrowLeft:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);
          activeSheet.selectCellLeft(activeSheet.selectedCell);
          break;

        case InteractionAction.arrowUp:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);
          activeSheet.selectCellAbove(activeSheet.selectedCell);
          break;

        case InteractionAction.arrowDown:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);
          activeSheet.selectCellBelow(activeSheet.selectedCell);
          break;

        case InteractionAction.otherKey:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          state = InteractionState.cellEditing;

          cellInputBoxViewModel.show(activeSheet.selectedCell);
          cellInputBoxViewModel.enterKey(keyboardEvent.key);
          cellInputBoxViewModel.positionCursorAtEnd();
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
          selectedDrawingTool = data;
          graphicsEditorViewModel.graphicsEditorView.selectDrawingTool(selectedDrawingTool);
          if (selectedDrawingTool == DrawingTool.selectionTool) {
            state = InteractionState.idle;
          } else {
            state = InteractionState.readyToDraw;
          }
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
          Map shapeData = data;
          // Add rectangle
          view.Rect rectView = new view.Rect(shapeData['x'], shapeData['y'], shapeData['width'], shapeData['height']);
          graphicsEditorViewModel.graphicsEditorView.shapeViews.add(rectView);
          graphicsEditorViewModel.graphicsEditorView.canvasElement.append(rectView.element);

          // Add sheet
          SheetViewModel sheet = graphicsEditorViewModel.sheetbook.addSheet(selectedDrawingTool == DrawingTool.rectangleTool ? 'RectSheet' : 'other');

          for (int i = 0; i < sheet.activeColumnNames.length; i++) {
            String value;
            switch (sheet.activeColumnNames[i]) {
              case 'Width':
                value = rectView.width.toString();
                break;
              case 'Height':
                value = rectView.height.toString();
                break;
              case 'Center X':
                value = rectView.x.toString();
                break;
              case 'Center Y':
                value = rectView.y.toString();
                break;
              case 'Corner Radius X':
                value = rectView.getAttribute('rx');
                break;
              case 'Corner Radius Y':
                value = rectView.getAttribute('ry');
                break;
              case 'Rotation':
                value = '0.0';
                break;
              case 'Fill Color':
                value = rectView.getAttribute('fill');
                break;
              case 'Fill Opacity':
                value = rectView.getAttribute('fill-opacity');
                break;
              case 'Border Style':
                value = 'solid';
                break;
              case 'Border Width':
                value = rectView.getAttribute('stroke-width');
                break;
              case 'Border Color':
                value = rectView.getAttribute('stroke');
                break;
              case 'Border Opacity':
                value = rectView.getAttribute('stroke-opacity');
                break;
              default:
                value = '';
                break;
            }
            // Update contents of current cell
            sheet.cells[0][i].commitFormula(value.toString());
          }

          // commit change to the rest of the application
          state = InteractionState.idle;
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

          activeSheet.selectedCell.commitFormula(cellInputBoxViewModel.contents.trim());
          activeSheet.selectCellBelow(activeSheet.selectedCell);

          state = InteractionState.idle;
          break;

        case InteractionAction.arrowRight:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          activeSheet.selectedCell.commitFormula(cellInputBoxViewModel.contents.trim());
          activeSheet.selectCellRight(activeSheet.selectedCell);

          state = InteractionState.idle;
          break;

        case InteractionAction.arrowLeft:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          activeSheet.selectedCell.commitFormula(cellInputBoxViewModel.contents.trim());
          activeSheet.selectCellLeft(activeSheet.selectedCell);

          state = InteractionState.idle;
          break;

        case InteractionAction.arrowUp:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          activeSheet.selectedCell.commitFormula(cellInputBoxViewModel.contents.trim());
          activeSheet.selectCellAbove(activeSheet.selectedCell);

          state = InteractionState.idle;
          break;

        case InteractionAction.arrowDown:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);

          activeSheet.selectedCell.commitFormula(cellInputBoxViewModel.contents.trim());
          activeSheet.selectCellBelow(activeSheet.selectedCell);

          state = InteractionState.idle;
          break;

        case InteractionAction.click:
          MouseEvent mouseEvent = data;
          stopDefaultBehaviour(mouseEvent);

          EventTarget eventTarget = mouseEvent.target;
          if (eventTarget is DivElement && eventTarget.classes.contains('cell-input')) {
              // Clicking inside the cell being edited => ignore
          } else {
            activeSheet.selectedCell.commitFormula(cellInputBoxViewModel.contents.trim());

            state = InteractionState.idle;

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

String propertyFromColumnName(String column) {
  switch (column) {
    case 'Width':
      return 'width';
      break;
    case 'Height':
      return 'height';
      break;
    case 'Center X':
      return 'x';
      break;
    case 'Center Y':
      return 'y';
      break;
    case 'Corner Radius X':
      return 'rx';
      break;
    case 'Corner Radius Y':
      return 'ry';
      break;
    case 'Rotation':
      return 'rotate';
      break;
    case 'Fill Color':
      return 'fill';
      break;
    case 'Fill Opacity':
      return 'fill-opacity';
      break;
    case 'Border Style':
      return 'border';
      break;
    case 'Border Width':
      return 'stroke-width';
      break;
    case 'Border Color':
      return 'stroke';
      break;
    case 'Border Opacity':
      return 'stroke-opacity';
      break;
    default:
      return column;
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
