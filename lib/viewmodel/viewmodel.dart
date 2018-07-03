library cuscus.viewmodel;

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html';
import 'dart:math' as math;
import 'dart:svg' as svg;

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
part 'cell_input_formula_bar.dart';
part 'shape_bounding_box.dart';

part 'layer_sheet_factory.dart';

part 'shape.dart';
part 'layer.dart';
part 'graphics_editor.dart';

part 'object_id.dart';

part 'spreadsheet.dart';


enum InteractionState { // Rename to uiState
  idle,
  readyToDraw,
  drawing,
  cellEditing,
  renamingSheet,
}
enum InteractionAction { // Rename to uiAction
  // actions on the visualisation
  clickInToolPanel,
  mouseDownOnCanvas,
  mouseUpOnCanvas,
  selectShape,

  // actions on sheets
  createNewSheet,
  selectSheet,
  renamingSheet,
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
  delete,
  capsLock,
  tab,
  arrowRight,
  arrowLeft,
  arrowUp,
  arrowDown,
  otherKey,
  mouseDownOnFillHandle,
}

enum DrawingTool {
  selectionTool,
  rectangleTool,
  ellipseTool,
  lineTool,
  curveTool,
  textTool,
}

enum Shape {
  rect,
  line
}

List<SheetViewModel> sheets = [];
List<SheetbookViewModel> sheetbooks = [];
SpreadsheetEngineViewModel spreadsheetEngineViewModel = new SpreadsheetEngineViewModel();

CellInputBoxViewModel cellInputBoxViewModel = new CellInputBoxViewModel();
CellInputFormulaBarViewModel cellInputFormulaBarViewModel = new CellInputFormulaBarViewModel();

SheetbookViewModel graphicsSheetbookViewModel;
GraphicsEditorViewModel graphicsEditorViewModel;

DivElement get _mainContainer => querySelector('#main-container'); // TODO: rename element to #main-container
DivElement get _spreadsheetsContainer => querySelector('#sheets-container'); // TODO: rename element to #spreadsheets-container

InteractionState _state = InteractionState.idle;
InteractionState get state => _state;
set state(InteractionState newState) {
  print('New state: $newState');
  _state = newState;
}

// State data
// For selecting a cell
SheetViewModel _activeSheet;
SheetViewModel get activeSheet => _activeSheet;
void set activeSheet(SheetViewModel sheet) {
  _activeSheet?.deselectCell();
  _activeSheet = sheet;
}

// For drawing
DrawingTool selectedDrawingTool;

init() {
  // Init layout elements.
  new box_layout.Box(_mainContainer);
  new box_layout.Box(querySelector("#spreadsheets-container"));
  new box_layout.Box(_spreadsheetsContainer);

  // Setup listeners to each other for the cell editors
  cellInputBoxViewModel.setupListeners();
  cellInputFormulaBarViewModel.setupListeners();

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
    graphicsSheetbookViewModel = new SheetbookViewModel();
    sheetbooks.add(graphicsSheetbookViewModel);
    graphicsSheetbookViewModel.createView(_spreadsheetsContainer.querySelector('#right-sheet'));

    graphicsEditorViewModel = new GraphicsEditorViewModel(graphicsSheetbookViewModel);
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
    } else if (keyEvent.key == "Delete") {
      command(InteractionAction.delete, keyEvent);
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

          EventTarget mouseTarget = mouseEvent.target;
          if (mouseTarget is TableCellElement) {
            TableCellElement cellElement = mouseTarget;
            SheetViewModel sheet = getSheetOfElement(cellElement);
            if (cellElement.attributes.containsKey('data-row') && cellElement.attributes.containsKey('data-col')) {
              int row = int.parse(cellElement.attributes['data-row']);
              int col = int.parse(cellElement.attributes['data-col']);
              sheet.selectCellAtCoords(row, col);
              if (sheet != activeSheet) {
                activeSheet = sheet;
              }
            } else {
              // TODO: implement column and row selection
            }
            state = InteractionState.idle;

          } else if (mouseTarget is DivElement && mouseTarget.id == "formula-editor") {
            cellInputBoxViewModel.show(activeSheet.selectedCell);
            cellInputFormulaBarViewModel.contents = activeSheet.selectedCell.formula;
            cellInputFormulaBarViewModel.focus();
            state = InteractionState.cellEditing;

          } else if (mouseTarget is svg.GeometryElement && mouseTarget.id != 'bounding-box-border') {
            svg.GeometryElement element = mouseTarget;
            List coordinates = element.id.split('-');
            int sheetId = int.parse(coordinates[0]);

            LayerViewModel layer = graphicsEditorViewModel.layers.singleWhere((layer) => layer.graphicsSheetViewModel.id == sheetId);
            graphicsEditorViewModel.selectLayer(layer);
            layer.selectShapeAtIndex(int.parse(coordinates[1]));

            SheetViewModel sheet = sheets.singleWhere((sheet) => sheet.id == sheetId);
            graphicsSheetbookViewModel.selectSheet(sheet);
            sheet.selectCellAtCoords(int.parse(coordinates[1]), 0);
            if (sheet != activeSheet) {
              activeSheet = sheet;
            }
          } else if (mouseTarget is svg.SvgSvgElement && mouseTarget.id == 'canvas') {
            graphicsEditorViewModel.selectedLayer.deselectShape();
            (graphicsSheetbookViewModel.selectedSheet as GraphicsSheetViewModel).deselectRow(activeSheet.selectedCell.row);
          }
          break;

        case InteractionAction.doubleClick:
          MouseEvent mouseEvent = data;
          stopDefaultBehaviour(mouseEvent);

          EventTarget eventTarget = mouseEvent.target;
          if (eventTarget is TableCellElement ||
            (eventTarget is DivElement && eventTarget.classes.contains('cell-selector'))) {
            cellInputBoxViewModel.show(activeSheet.selectedCell);
            cellInputBoxViewModel.focus();
            cellInputFormulaBarViewModel.contents = activeSheet.selectedCell.formula;
            state = InteractionState.cellEditing;
          }
          break;

        case InteractionAction.enter:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);
          cellInputBoxViewModel.show(activeSheet.selectedCell);
          cellInputBoxViewModel.focus();
          cellInputFormulaBarViewModel.contents = activeSheet.selectedCell.formula;
          state = InteractionState.cellEditing;
          break;

        case InteractionAction.backspace:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);
          activeSheet.selectedCell.commitFormulaString('');
          cellInputFormulaBarViewModel.contents = activeSheet.selectedCell.formula;
          break;

        case InteractionAction.delete:
          KeyboardEvent keyboardEvent = data;
          stopDefaultBehaviour(keyboardEvent);
          activeSheet.selectedCell.commitFormulaString('');
          cellInputFormulaBarViewModel.contents = activeSheet.selectedCell.formula;
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

          if (keyboardEvent.ctrlKey || keyboardEvent.metaKey) {
            if (keyboardEvent.metaKey) {
              if (keyboardEvent.key == 'b') {
                activeSheet.selectedCell.cellView.cellElement.classes.toggle('bold');
              }
              if (keyboardEvent.key == 'i') {
                activeSheet.selectedCell.cellView.cellElement.classes.toggle('italic');
              }
            }
            return;
          }
          stopDefaultBehaviour(keyboardEvent);

          state = InteractionState.cellEditing;

          cellInputBoxViewModel.show(activeSheet.selectedCell);
          cellInputBoxViewModel.enterKey(keyboardEvent.key);
          cellInputBoxViewModel.positionCursorAtEnd();
          break;

        case InteractionAction.mouseDownOnFillHandle:
          MouseEvent mouseDown = data;
          stopDefaultBehaviour(mouseDown);

          DivElement fillHandle = mouseDown.target;
          DivElement selectionBorder = fillHandle.nextElementSibling;
          int startPositionY = mouseDown.client.y;
          int cellWidth = activeSheet.selectedCell.cellView.cellElement.client.width;
          int cellHeight = activeSheet.selectedCell.cellView.cellElement.client.height;

          selectionBorder.style
            ..visibility = 'visible'
            ..top = '${activeSheet.selectedCell.cellView.cellElement.offset.top + 21}px'
            ..left = '${activeSheet.selectedCell.cellView.cellElement.offset.left + 31}px'
            ..width = '${cellWidth}px';

          StreamSubscription dragMoveSub;
          StreamSubscription dragEndSub;

          dragMoveSub = document.onMouseMove.listen((MouseEvent mouseMove) {
            int yDelta = mouseMove.client.y - startPositionY;
            if (yDelta < 0) {
              selectionBorder.style.height = '${cellHeight}px';
              return;
            }

            int rowsDown = (yDelta.toDouble() / cellHeight.toDouble()).floor() + 2;

            selectionBorder.style.height = '${(cellHeight + 1) * rowsDown - 1}px';
          });

          dragEndSub = document.onMouseUp.listen((MouseEvent mouseUp) {
            int yDelta = mouseUp.client.y - startPositionY;
            selectionBorder.style.visibility = 'hidden';

            if (yDelta < 0) {
              return;
            }

            int rowsDown = (yDelta.toDouble() / cellHeight.toDouble()).floor() + 2;
            Map<int, List<int>> cellsToFillIn = {};
            for (int row = activeSheet.selectedCell.row + 1; row < activeSheet.selectedCell.row + rowsDown; row++) {
              cellsToFillIn[row] = [activeSheet.selectedCell.column];
            }

            selectionBorder.style.height = '0px';

            activeSheet.fillInCellsWithCell(cellsToFillIn, activeSheet.selectedCell);
            activeSheet.selectCellAtCoords(activeSheet.selectedCell.row + rowsDown - 1, activeSheet.selectedCell.column);

            dragMoveSub.cancel();
            dragEndSub.cancel();
          });

          break;

        case InteractionAction.renamingSheet:
          state = InteractionState.renamingSheet;
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

          Shape shape;
          switch (selectedDrawingTool) {
            case DrawingTool.rectangleTool:
              shape = Shape.rect;
              break;
            case DrawingTool.lineTool:
              shape = Shape.line;
              break;
            default:
              throw "Shape tool unsupported, got: $selectedDrawingTool";
          }

          LayerSheetFactory layerSheetFactory = new LayerSheetFactory(shape);
          GraphicsSheetViewModel sheet = layerSheetFactory.sheet;
          LayerViewModel layer = layerSheetFactory.layer;

          switch (shape) {
            case Shape.rect:
              layer.addShape(0, {Rect.x: shapeData['x'], Rect.y: shapeData['y'], Rect.width: shapeData['width'], Rect.height: shapeData['height']});
              break;
            case Shape.line:
              layer.addShape(0, {Line.x1: shapeData['x1'], Line.y1: shapeData['y1'], Line.x2: shapeData['x2'], Line.y2: shapeData['y2']});
              break;
          }

          sheet.updateRow(0); // TODO: this is a hack
          layer.selectShapeAtIndex(0);
          activeSheet = sheet;
          activeSheet.selectCellAtCoords(0, 0);

          state = InteractionState.idle;
          command(InteractionAction.clickInToolPanel, DrawingTool.selectionTool);
          break;

        case InteractionAction.escape:
          graphicsEditorViewModel.graphicsEditorView.cancelDrawing();
          state = InteractionState.idle;
          command(InteractionAction.clickInToolPanel, DrawingTool.selectionTool);
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

          activeSheet.selectedCell.commitFormulaString(cellInputBoxViewModel.contents.trim());
          activeSheet.selectCellBelow(activeSheet.selectedCell);
          cellInputBoxViewModel.hide();
          cellInputFormulaBarViewModel.unfocus();

          state = InteractionState.idle;
          break;

        case InteractionAction.escape:
          KeyboardEvent keyEvent = data;
          stopDefaultBehaviour(keyEvent);

          cellInputBoxViewModel.hide();
          cellInputFormulaBarViewModel.contents = activeSheet.selectedCell.formula;
          cellInputFormulaBarViewModel.unfocus();

          state = InteractionState.idle;
          break;

        case InteractionAction.click:
          MouseEvent mouseEvent = data;
          stopDefaultBehaviour(mouseEvent);

          EventTarget eventTarget = mouseEvent.target;
          if (eventTarget is DivElement && eventTarget.classes.contains('cell-input')) {
              // Clicking inside the cell being edited => ignore
          } else if (eventTarget is DivElement && eventTarget.id == 'formula-editor') {
            // Clicking in the formula bar => ignore
          } else {
            activeSheet.selectedCell.commitFormulaString(cellInputBoxViewModel.contents.trim());

            state = InteractionState.idle;

            // Process the click
            command(InteractionAction.click, data);
          }
          break;

        default:
          break;
      }
      break;

    case InteractionState.renamingSheet:
      switch (action) {
        case InteractionAction.renameSheet:
          if (data != null) {
            SheetViewModel sheet = data[0];
            String newName = data[1];

            sheet.name = newName;
          }
          state = InteractionState.idle;
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


// TODO: move to another file
enum Rect {
  x,
  y,
  width,
  height,
  rx,
  ry,
  fillColor,
  fillOpacity,
  strokeColor,
  strokeWidth,
  strokeOpacity,
  opacity
}

const Map<Rect, String> rectPropertyToColumnName = const {
  Rect.width: 'Width',
  Rect.height: 'Height',
  Rect.x: 'X',
  Rect.y: 'Y',
  Rect.rx: 'CornerRadiusX',
  Rect.ry: 'CornerRadiusY',
  Rect.fillColor: 'FillColor',
  Rect.fillOpacity: 'FillOpacity',
  Rect.strokeColor: 'BorderColor',
  Rect.strokeWidth: 'BorderWidth',
  Rect.strokeOpacity: 'BorderOpacity',
  Rect.opacity: 'Opacity'
};

Map<String, Rect> _columnNameToRectProperty = {};
Map<String, Rect> get columnNameToRectProperty {
  if (_columnNameToRectProperty.isEmpty) {
    rectPropertyToColumnName.forEach((rect, column) => _columnNameToRectProperty[column] = rect);
  }
  return _columnNameToRectProperty;
}

const Map<Rect, String> rectPropertyToSvgProperty = const {
  Rect.width: 'width',
  Rect.height: 'height',
  Rect.x: 'x',
  Rect.y: 'y',
  Rect.rx: 'rx',
  Rect.ry: 'ry',
  Rect.fillColor: 'fill',
  Rect.fillOpacity: 'fill-opacity',
  Rect.strokeColor: 'stroke',
  Rect.strokeWidth: 'stroke-width',
  Rect.strokeOpacity: 'stroke-opacity',
  Rect.opacity: 'opacity'
};

Map<String, Rect> _svgPropertyToRectProperty = {};
Map<String, Rect> get svgPropertyToRectProperty {
  if (_svgPropertyToRectProperty.isEmpty) {
    rectPropertyToSvgProperty.forEach((rect, property) => _svgPropertyToRectProperty[property] = rect);
  }
  return _svgPropertyToRectProperty;
}

/**** Line */

enum Line {
  x1,
  y1,
  x2,
  y2,
  strokeColor,
  strokeWidth,
  strokeOpacity,
}

const Map<Line, String> linePropertyToColumnName = const {
  Line.x1: 'StartX',
  Line.y1: 'StartY',
  Line.x2: 'EndX',
  Line.y2: 'EndY',
  Line.strokeColor: 'Color',
  Line.strokeWidth: 'Width',
  Line.strokeOpacity: 'Opacity',
};

Map<String, Line> _columnNameToLineProperty = {};
Map<String, Line> get columnNameToLineProperty {
  if (_columnNameToLineProperty.isEmpty) {
    linePropertyToColumnName.forEach((line, column) => _columnNameToLineProperty[column] = line);
  }
  return _columnNameToLineProperty;
}

const Map<Line, String> linePropertyToSvgProperty = const {
  Line.x1: 'x1',
  Line.y1: 'y1',
  Line.x2: 'x2',
  Line.y2: 'y2',
  Line.strokeColor: 'stroke',
  Line.strokeWidth: 'stroke-width',
  Line.strokeOpacity: 'stroke-opacity',
};

Map<String, Line> _svgPropertyToLineProperty = {};
Map<String, Line> get svgPropertyToLineProperty {
  if (_svgPropertyToLineProperty.isEmpty) {
    linePropertyToSvgProperty.forEach((line, property) => _svgPropertyToLineProperty[property] = line);
  }
  return _svgPropertyToLineProperty;
}
