library cuscus.viewmodel;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math' as math;
import 'dart:svg' as svg;

// Import the model
import 'package:cuscus/model/execution_engine/spreadsheet.dart' as engine;
import 'package:cuscus/model/formula_parser/formula_parser.dart' as parser;

// Import the view
import 'package:cuscus/view/view.dart' as view;

// Import the utils
import 'package:cuscus/utils/utils.dart' as utils;

part 'cell.dart';
part 'sheet.dart';
part 'sheetbook.dart';
part 'sheetbooks_manager.dart';

part 'shape.dart';
part 'layer.dart';
part 'layerbook.dart';
part 'layerbooks_manager.dart';

part 'cell_input.dart';
part 'shape_bounding_box.dart';

part 'object_id.dart';

part 'spreadsheet_engine.dart';

part 'shape_properties_helper.dart';


enum UIState {
  idle,
  readyToDraw,
  drawing,
  cellEditing,
  renamingSheet,
}

enum UIAction {
  // actions on the visualisation
  selectGraphicsTool,
  startDrawing,
  endDrawing,
  clickOnShape,
  clickOnCanvas,
  mouseDownOnFillHandle,

  // actions on sheets
  createNewSheet,
  selectSheet,
  startRenameSheet,
  endRenameSheet,
  deleteSheet,

  // actions on spreadsheet cells
  clickOnCell,
  doubleClickOnCell,

  clickOnFormulaBar,

  // keyboard actions
  enter,
  escape,
  backspace,
  delete,
  tab,
  arrowRight,
  arrowLeft,
  arrowUp,
  arrowDown,
  otherKey,
}

enum SheetbookType {
  data,
  graphics,
}

SheetbookType getSheetbookType(String type) {
  switch(type) {
    case 'SheetbookType.data':
      return SheetbookType.data;
    case 'SheetbookType.graphics':
      return SheetbookType.graphics;
    default:
      throw 'Unknown sheetbook type: $type';
  }
}

enum DrawingTool {
  selectionTool,
  rectangleTool,
  ellipseTool,
  lineTool,
  curveTool,
  textTool,
}

enum GraphicMarkType {
  rect,
  ellipse,
  line,
  text,
}

GraphicMarkType getGraphicMarkType(String type) {
  switch(type) {
    case 'GraphicMarkType.rect':
      return GraphicMarkType.rect;
    case 'GraphicMarkType.ellipse':
      return GraphicMarkType.ellipse;
    case 'GraphicMarkType.line':
      return GraphicMarkType.line;
    case 'GraphicMarkType.text':
      return GraphicMarkType.text;
    default:
      throw 'Unknown graphic mark type: $type';
  }
}

final Map<DrawingTool, GraphicMarkType> toolToGraphicMark = {
  DrawingTool.rectangleTool: GraphicMarkType.rect,
  DrawingTool.ellipseTool: GraphicMarkType.ellipse,
  DrawingTool.lineTool: GraphicMarkType.line,
  DrawingTool.textTool: GraphicMarkType.text,
};

final Map<GraphicMarkType, DrawingTool> graphicMarkToTool = {
  GraphicMarkType.rect: DrawingTool.rectangleTool,
  GraphicMarkType.ellipse: DrawingTool.ellipseTool,
  GraphicMarkType.line: DrawingTool.lineTool,
  GraphicMarkType.text: DrawingTool.textTool,
};

AppController get appController => _appController;

AppController _appController;

void init() {
  view.init();
  SpreadsheetEngineViewModel.init();

  // Setup singleton widgets
  setupCellInput();
  setupBoundingBox();

  _appController = new AppController();
}

class AppController {
  List<SheetbookViewModel> sheetbooks = [];
  List<SheetbookViewModel> get graphicsSheetbooks => sheetbooks.where((sheetbook) => sheetbook.type == SheetbookType.graphics).toList();
  List<LayerbookViewModel> get graphicsLayerbooks => graphicsSheetbooks.map((sheetbook) => sheetbook.layerbook).toList();

  // Application state
  UIState _state = UIState.idle;
  UIState get state => _state;
  set state(UIState newState) => _state = newState;

  AppController() {
    setupListeners();
    loadEmptySession();
  }

  void setupListeners() {
    // Setup listeners
    view.loadWorkspaceButton.onChange.listen((event) {
      utils.stopDefaultBehaviour(event);
      var fileReader = new FileReader();
      fileReader.onLoadEnd.listen((event) {
        var workspaceJson = jsonDecode(fileReader.result);
        utils.validateWorkspaceSerialisation(workspaceJson);
        clearWorkspace();
        loadCuscusWorkspace(workspaceJson);
      });
      fileReader.readAsText(view.loadWorkspaceButton.files.first);
      view.loadWorkspaceButton.value = "";
    });

    view.saveWorkspaceButton.onClick.listen((event) {
      utils.stopDefaultBehaviour(event);
      Map cuscusSession = saveCuscusSession();
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      Blob blob = new Blob([encoder.convert(cuscusSession)], 'application/json');
      AnchorElement tempAnchor = new AnchorElement();
      tempAnchor
        ..download = 'workspace.json'
        ..href = Url.createObjectUrlFromBlob(blob);
      document.body.append(tempAnchor);
      tempAnchor.click();
      tempAnchor.remove();
    });

    view.drawingToolContainer.querySelectorAll(".drawing-tool.button").forEach((toolButton) {
      if (toolButton.attributes.containsKey('disabled')) return;
      toolButton.onClick.listen((event) {
        utils.stopDefaultBehaviour(event);
        command(UIAction.selectGraphicsTool, view.buttonIdToDrawingTool(toolButton.id));
      });
    });

    view.visCanvas.onMouseDown.listen((mouseDown) {
      command(UIAction.startDrawing, mouseDown);
    });

    document.onClick.listen((MouseEvent click) {
      EventTarget mouseTarget = click.target;

      if (mouseTarget is TableCellElement) {
        utils.stopDefaultBehaviour(click);
        SheetViewModel sheet = _getSheetOfElement(mouseTarget);
        if (mouseTarget.attributes.containsKey('data-row') && mouseTarget.attributes.containsKey('data-col')) {
          int row = int.parse(mouseTarget.attributes['data-row']);
          int col = int.parse(mouseTarget.attributes['data-col']);
          command(UIAction.clickOnCell, sheet.cells[row][col]);
        } else {
          // TODO: implement column and row selection
        }
      } else if (mouseTarget is DivElement && mouseTarget.id == "formula-editor") {
        utils.stopDefaultBehaviour(click);
        command(UIAction.clickOnFormulaBar, null);
      } else if (mouseTarget is svg.GraphicsElement && mouseTarget.classes.contains('shape')) {
        utils.stopDefaultBehaviour(click);
        LayerViewModel layer = _getLayerOfElement(mouseTarget);
        ShapeViewModel shape = layer.shapes[int.parse(mouseTarget.attributes['data-index'])];
        command(UIAction.clickOnShape, shape);
      } else if (mouseTarget == view.visCanvas) {
        utils.stopDefaultBehaviour(click);
        command(UIAction.clickOnCanvas, null);
      }
    });
    document.onDoubleClick.listen((Event doubleclick) {
      EventTarget mouseTarget = doubleclick.target;
      utils.stopDefaultBehaviour(doubleclick);
      if (mouseTarget is TableCellElement) {
        if (mouseTarget.attributes.containsKey('data-row') && mouseTarget.attributes.containsKey('data-col')) {
          command(UIAction.doubleClickOnCell, null);
        }
      } else if (mouseTarget is DivElement && mouseTarget.classes.contains('cell-selector')) {
        command(UIAction.doubleClickOnCell, null);
      }
    });
    document.onKeyDown.listen((KeyboardEvent keyEvent) {
      if (keyEvent.key == "Enter") {
        command(UIAction.enter, keyEvent);
      } else if (keyEvent.key == "Escape") {
        command(UIAction.escape, keyEvent);
      } else if (keyEvent.key == "Backspace") {
        command(UIAction.backspace, keyEvent);
      } else if (keyEvent.key == "Delete") {
        command(UIAction.delete, keyEvent);
      } else if (keyEvent.key == "Tab") {
        command(UIAction.tab, keyEvent);
      } else if (keyEvent.key == "ArrowRight") {
        command(UIAction.arrowRight, keyEvent);
      } else if (keyEvent.key == "ArrowLeft") {
        command(UIAction.arrowLeft, keyEvent);
      } else if (keyEvent.key == "ArrowUp") {
        command(UIAction.arrowUp, keyEvent);
      } else if (keyEvent.key == "ArrowDown") {
        command(UIAction.arrowDown, keyEvent);
      } else {
        command(UIAction.otherKey, keyEvent);
      }
    });
  }

  void createNewSheetbook({int index, bool isGraphicsSheetbook: false}) {
    if (index == null || index > sheetbooks.length) {
      index = sheetbooks.length;
    }
    SheetbookType sheetbookType = isGraphicsSheetbook ? SheetbookType.graphics : SheetbookType.data;
    sheetbooks.insert(index, new SheetbookViewModel(sheetbookType));
  }

  void loadSheetbook(Map sheetbookInfo) {
    sheetbooks.add(new SheetbookViewModel.load(sheetbookInfo));
  }

  command(UIAction action, var data) {
    switch (state) {
      /*
      * State: idle
      */
      case UIState.idle:

        switch (action) {
          case UIAction.selectGraphicsTool:
            view.selectedTool = data;
            if (view.selectedTool == DrawingTool.selectionTool) {
              state = UIState.idle;
            } else {
              state = UIState.readyToDraw;
            }
            break;

          case UIAction.clickOnCell:
            (data as CellViewModel).select();
            state = UIState.idle;
            break;

          case UIAction.clickOnFormulaBar:
            CellInputBoxViewModel.show(CellViewModel.selectedCell);
            CellInputFormulaBarViewModel.contents = CellViewModel.selectedCell.formula;
            CellInputFormulaBarViewModel.focus();
            state = UIState.cellEditing;
            break;

          case UIAction.clickOnShape:
            ShapeViewModel shape = data;
            shape.layer.focus();
            shape.select();

            GraphicsSheetViewModel sheet = shape.layer.graphicsSheetViewModel;
            sheet.focus();
            sheet.cells[shape.index][0].select();
            break;

          case UIAction.clickOnCanvas:
            if (ShapeViewModel.selectedShape != null) {
              ShapeViewModel.selectedShape.layer.graphicsSheetViewModel.deselectRow(ShapeViewModel.selectedShape.index);
              ShapeViewModel.selectedShape.deselect();
            }
            break;

          case UIAction.doubleClickOnCell:
            CellInputBoxViewModel.show(CellViewModel.selectedCell);
            CellInputBoxViewModel.focus();
            CellInputFormulaBarViewModel.contents = CellViewModel.selectedCell.formula;
            state = UIState.cellEditing;
            break;

          case UIAction.enter:
            KeyboardEvent keyboardEvent = data;
            utils.stopDefaultBehaviour(keyboardEvent);
            CellInputBoxViewModel.show(CellViewModel.selectedCell);
            CellInputBoxViewModel.focus();
            CellInputFormulaBarViewModel.contents = CellViewModel.selectedCell.formula;
            state = UIState.cellEditing;
            break;

          case UIAction.backspace:
            KeyboardEvent keyboardEvent = data;
            utils.stopDefaultBehaviour(keyboardEvent);
            CellViewModel.selectedCell.setContentsString('');
            CellViewModel.selectedCell.commitContents();
            CellInputFormulaBarViewModel.contents = CellViewModel.selectedCell.formula;
            break;

          case UIAction.delete:
            KeyboardEvent keyboardEvent = data;
            utils.stopDefaultBehaviour(keyboardEvent);
            CellViewModel.selectedCell.setContentsString('');
            CellViewModel.selectedCell.commitContents();
            CellInputFormulaBarViewModel.contents = CellViewModel.selectedCell.formula;
            break;

          case UIAction.tab:
          case UIAction.arrowRight:
            KeyboardEvent keyboardEvent = data;
            utils.stopDefaultBehaviour(keyboardEvent);
            CellViewModel.selectedCell.selectCellRight();
            break;

          case UIAction.arrowLeft:
            KeyboardEvent keyboardEvent = data;
            utils.stopDefaultBehaviour(keyboardEvent);
            CellViewModel.selectedCell.selectCellLeft();
            break;

          case UIAction.arrowUp:
            KeyboardEvent keyboardEvent = data;
            utils.stopDefaultBehaviour(keyboardEvent);
            CellViewModel.selectedCell.selectCellAbove();
            break;

          case UIAction.arrowDown:
            KeyboardEvent keyboardEvent = data;
            utils.stopDefaultBehaviour(keyboardEvent);
            CellViewModel.selectedCell.selectCellBelow();
            break;

          case UIAction.otherKey:
            KeyboardEvent keyboardEvent = data;

            if (keyboardEvent.ctrlKey || keyboardEvent.metaKey) {
              if (keyboardEvent.metaKey) {
                if (keyboardEvent.key == 'b') {
                  CellViewModel.selectedCell.cellView.uiElement.classes.toggle('bold');
                }
                if (keyboardEvent.key == 'i') {
                  CellViewModel.selectedCell.cellView.uiElement.classes.toggle('italic');
                }
              }
              return;
            }
            utils.stopDefaultBehaviour(keyboardEvent);

            state = UIState.cellEditing;

            CellInputBoxViewModel.show(CellViewModel.selectedCell);
            CellInputBoxViewModel.enterKey(keyboardEvent.key);
            CellInputBoxViewModel.positionCursorAtEnd();
            break;

          case UIAction.mouseDownOnFillHandle:
            MouseEvent mouseDown = data;
            utils.stopDefaultBehaviour(mouseDown);

            DivElement fillHandle = mouseDown.target;
            DivElement selectionBorder = fillHandle.nextElementSibling;
            int startPositionY = mouseDown.client.y;
            int cellWidth = CellViewModel.selectedCell.cellView.uiElement.client.width;
            int cellHeight = CellViewModel.selectedCell.cellView.uiElement.client.height;

            selectionBorder.style
              ..visibility = 'visible'
              ..top = '${CellViewModel.selectedCell.cellView.uiElement.offset.top + 21}px'
              ..left = '${CellViewModel.selectedCell.cellView.uiElement.offset.left + 31}px'
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
              for (int row = CellViewModel.selectedCell.row + 1; row < CellViewModel.selectedCell.row + rowsDown; row++) {
                cellsToFillIn[row] = [CellViewModel.selectedCell.column];
              }

              selectionBorder.style.height = '0px';

              SheetViewModel.activeSheet.fillInCellsWithCell(cellsToFillIn, CellViewModel.selectedCell);
              SheetViewModel.activeSheet.cells[CellViewModel.selectedCell.row + rowsDown - 1][CellViewModel.selectedCell.column].select();

              dragMoveSub.cancel();
              dragEndSub.cancel();
            });

            break;

          case UIAction.startRenameSheet:
            state = UIState.renamingSheet;
            break;

          default:
            break;
        }
        break;

      /*
      * State: readyToDraw
      */
      case UIState.readyToDraw:
        switch (action) {
          case UIAction.selectGraphicsTool:
            view.selectedTool = data;
            if (view.selectedTool == DrawingTool.selectionTool) {
              state = UIState.idle;
            } else {
              state = UIState.readyToDraw;
            }
            break;

          case UIAction.startDrawing:
            MouseEvent mouseDown = data;
            utils.stopDefaultBehaviour(mouseDown);
            view.startDrawing(mouseDown);
            state = UIState.drawing;
            break;

          default:
            break;
        }
        break;

      /*
      * State: drawing
      */
      case UIState.drawing:
        switch (action) {
          case UIAction.endDrawing:
            Map shapeData = data;

            GraphicMarkType mark = toolToGraphicMark[view.selectedTool];
            if (mark == null) {
              throw "Shape tool unsupported, got: ${view.selectedTool}";
            }

            if (LayerbookViewModel.activeLayerbook == null) {
              createNewSheetbook(isGraphicsSheetbook: true);
            }

            GraphicsSheetViewModel sheet = new SheetViewModel(graphicsSheetbooks.first, mark);

            switch (mark) {
              case GraphicMarkType.rect:
                sheet.layerViewModel.addShape(0, {Rect.x: shapeData['x'], Rect.y: shapeData['y'], Rect.width: shapeData['width'], Rect.height: shapeData['height']});
                break;
              case GraphicMarkType.line:
                sheet.layerViewModel.addShape(0, {Line.x1: shapeData['x1'], Line.y1: shapeData['y1'], Line.x2: shapeData['x2'], Line.y2: shapeData['y2']});
                break;
              default:
                break;
            }

            sheet.updateRow(0); // TODO: this is a hack
            sheet.layerViewModel.shapes[0].select();
            sheet.focus();
            sheet.cells[0][0].select();

            state = UIState.idle;
            command(UIAction.selectGraphicsTool, DrawingTool.selectionTool);
            break;

          case UIAction.escape:
            view.cancelDrawing();
            state = UIState.idle;
            command(UIAction.selectGraphicsTool, DrawingTool.selectionTool);
            break;

          default:
            break;
        }
        break;

      /*
      * State: cellEditing
      */
      case UIState.cellEditing:
        switch (action) {
          case UIAction.enter:
            KeyboardEvent keyEvent = data;
            utils.stopDefaultBehaviour(keyEvent);

            CellViewModel.selectedCell.setContentsString(CellInputBoxViewModel.contents.trim());
            CellViewModel.selectedCell.commitContents();
            CellViewModel.selectedCell.selectCellBelow();
            CellInputBoxViewModel.hide();
            CellInputFormulaBarViewModel.unfocus();

            state = UIState.idle;
            break;

          case UIAction.escape:
            KeyboardEvent keyEvent = data;
            utils.stopDefaultBehaviour(keyEvent);

            CellInputBoxViewModel.hide();
            CellInputFormulaBarViewModel.contents = CellViewModel.selectedCell.formula;
            CellInputFormulaBarViewModel.unfocus();

            state = UIState.idle;
            break;

          case UIAction.clickOnCell:
            CellViewModel.selectedCell.setContentsString(CellInputBoxViewModel.contents.trim());
            CellViewModel.selectedCell.commitContents();
            CellInputBoxViewModel.hide();
            CellInputFormulaBarViewModel.unfocus();

            state = UIState.idle;
            // Process the click
            command(UIAction.clickOnCell, data);
            break;

          default:
            break;
        }
        break;

      case UIState.renamingSheet:
        switch (action) {
          case UIAction.endRenameSheet:
            if (data != null) {
              SheetViewModel sheet = data[0];
              String newName = data[1];

              sheet.name = newName;
            }
            state = UIState.idle;
            break;
          default:
            break;
        }
        break;
    }
  }

  LayerViewModel _getLayerOfElement(Element element) {
    print('asa');
    svg.GElement layerContainer = _getAncestors(element).firstWhere((ancestor) => ancestor.classes.contains('layer'));
    print(layerContainer);
    int layerId = int.parse(layerContainer.getAttribute('data-layer-id'));
    print(layerId);
    return LayerViewModel.layers.singleWhere((layer) => layer.id == layerId);
  }

  SheetViewModel _getSheetOfElement(Element element) {
    DivElement sheetContainer = _getAncestors(element).firstWhere((ancestor) => ancestor.classes.contains('sheet'));
    int sheetId = int.parse(sheetContainer.getAttribute('data-sheet-id'));
    return SheetViewModel.sheets.singleWhere((sheet) => sheet.id == sheetId);
  }

  List<Element> _getAncestors(Element element) {
    List<Element> ancestors = [element];
    while (element != null) {
      ancestors.add(element);
      element = element.parent;
    }
    return ancestors;
  }

loadEmptySession() {
  // Create the incoming data spreadsheet
  {
    SheetbookViewModel sheetbook = new SheetbookViewModel();
    sheetbooks.add(sheetbook);
    sheetbook.addSheet();
  }

  // Create the data wrangling spreadsheet
  {
    SheetbookViewModel sheetbook = new SheetbookViewModel();
    sheetbooks.add(sheetbook);
    sheetbook.addSheet();
  }
}

  clearWorkspace() {
    sheetbooks?.clear();
    objectsWithId?.clear();

    SheetbookViewModel.clear();
    LayerbookViewModel.clear();
    SheetViewModel.clear();
    LayerViewModel.clear();
    CellViewModel.clear();
    ShapeViewModel.clear();
    SpreadsheetEngineViewModel.clear();

    state = UIState.idle;
    view.sheetbooksContainer.innerHtml = "";
    view.visCanvas.innerHtml = "";
  }
  loadCuscusWorkspace(cuscusWorkspace) {
    cuscusWorkspace["sheetbooks"].forEach((sheetbookInfo) {
      sheetbooks.add(new SheetbookViewModel.load(sheetbookInfo));
    });

    SpreadsheetEngineViewModel.spreadsheet.updateDependencyGraph();
  }

  Map saveCuscusSession() {
    Map workspace = {"sheetbooks": []};
    sheetbooks.forEach((sheetbook) {
      workspace["sheetbooks"].add(sheetbook.save());
    });
    return workspace;
  }
}
