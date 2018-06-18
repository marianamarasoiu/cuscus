library playground;

import 'package:cuscus/viewmodel/viewmodel.dart' as viewmodel;

void init() => viewmodel.init();

void setup() {
  {
    List<List<viewmodel.CellViewModel>> spreadsheetCells = viewmodel.sheetbooks[0].selectedSheet.cells;
    for (int row = 0; row < inputData.length; row++) {
      for (int col = 0; col < inputData[row].length; col++) {
        spreadsheetCells[row][col].commitFormulaString(inputData[row][col]);
      }
    }
  }

  {
    List<List<viewmodel.CellViewModel>> spreadsheetCells = viewmodel.sheetbooks[1].selectedSheet.cells;
    spreadsheetCells[0][0].commitFormulaString('Row index');
    for (int row = 0; row < otherData.length; row++) {
      spreadsheetCells[row+1][0].commitFormulaString(otherData[row][0]);
    }
  }

  {
    List<List<viewmodel.CellViewModel>> spreadsheetCells = viewmodel.sheetbooks[1].selectedSheet.cells;
    spreadsheetCells[0][2].commitFormulaString('Average stock');
    for (int row = 0; row < otherData.length; row++) {
      spreadsheetCells[row+1][2].commitFormulaString('=Average(Sheet1!B${row+2}:Sheet1!D${row+2})');
    }
  }

  {
    viewmodel.LayerSheetFactory layerSheetFactory = new viewmodel.LayerSheetFactory(viewmodel.Shape.rect);
    viewmodel.GraphicsSheetViewModel sheet = layerSheetFactory.sheet;
    viewmodel.LayerViewModel layer = layerSheetFactory.layer;

    layer.addShape(0, {
      viewmodel.Rect.x: 500,
      viewmodel.Rect.y: 50,
      viewmodel.Rect.width: 0,
      viewmodel.Rect.height: 10});
    sheet.updateRow(0);
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.width])].commitFormulaString('=Sheet1!B2 * 5');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.y])].commitFormulaString('=Sheet2!A2 * 50');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.fillColor])].commitFormulaString('#efc45f');

    sheet.cells[1][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[2][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[3][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[4][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[5][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[6][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
  }

  {
    viewmodel.LayerSheetFactory layerSheetFactory = new viewmodel.LayerSheetFactory(viewmodel.Shape.rect);
    viewmodel.GraphicsSheetViewModel sheet = layerSheetFactory.sheet;
    viewmodel.LayerViewModel layer = layerSheetFactory.layer;

    layer.addShape(0, {
      viewmodel.Rect.x: 500,
      viewmodel.Rect.y: 60,
      viewmodel.Rect.width: 0,
      viewmodel.Rect.height: 10});
    sheet.updateRow(0);
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.width])].commitFormulaString('=Sheet1!C2 * 5');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.y])].commitFormulaString('=10 + Sheet2!A2 * 50');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.fillColor])].commitFormulaString('#a675ef');

    sheet.cells[1][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[2][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[3][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[4][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[5][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[6][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
  }


  {
    viewmodel.LayerSheetFactory layerSheetFactory = new viewmodel.LayerSheetFactory(viewmodel.Shape.rect);
    viewmodel.GraphicsSheetViewModel sheet = layerSheetFactory.sheet;
    viewmodel.LayerViewModel layer = layerSheetFactory.layer;

    layer.addShape(0, {
      viewmodel.Rect.x: 500,
      viewmodel.Rect.y: 70,
      viewmodel.Rect.width: 0,
      viewmodel.Rect.height: 10});
    sheet.updateRow(0);
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.width])].commitFormulaString('=Sheet1!D2 * 5');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.y])].commitFormulaString('=20 + Sheet2!A2 * 50');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.fillColor])].commitFormulaString('#75c4ef');

    sheet.cells[1][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[2][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[3][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[4][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[5][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
    sheet.cells[6][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('500');
  }

  {
    viewmodel.LayerSheetFactory layerSheetFactory = new viewmodel.LayerSheetFactory(viewmodel.Shape.line);
    viewmodel.GraphicsSheetViewModel sheet = layerSheetFactory.sheet;
    viewmodel.LayerViewModel layer = layerSheetFactory.layer;

    layer.addShape(0, {
      viewmodel.Line.x1: 700,
      viewmodel.Line.y1: 65,
      viewmodel.Line.x2: 700,
      viewmodel.Line.y2: 115});
    sheet.updateRow(0);
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.x1])].commitFormulaString('=500 + Sheet2!C2 * 5');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.x2])].commitFormulaString('=500 + Sheet2!C3 * 5');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.y1])].commitFormulaString('=15 + Sheet2!A2 * 50');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.y2])].commitFormulaString('=15 + Sheet2!A3 * 50');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.strokeWidth])].commitFormulaString('2');

    sheet.cells[1][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.strokeOpacity])].commitFormulaString('1');
    sheet.cells[2][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.strokeOpacity])].commitFormulaString('1');
    sheet.cells[3][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.strokeOpacity])].commitFormulaString('1');
    sheet.cells[4][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.strokeOpacity])].commitFormulaString('1');
    sheet.cells[5][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.strokeOpacity])].commitFormulaString('1');
  }
}

final List<List> inputData = [
  ['Fruit', 'London', 'Manchester', 'Edinburgh'],
  ['Apple', '45', '50', '43'],
  ['Banana', '39', '37', '40'],
  ['Blueberry', '28', '36', '34'],
  ['Cherry', '18', '12', '12'],
  ['Grapes', '32', '30', '35'],
  ['Peach', '35', '38', '35'],
  ['Orange', '24', '20', '25'],
  ['Strawberry', '48', '44', '46'],
];

final List<List> otherData = [
  [1],
  [2],
  [3],
  [4],
  [5],
  [6],
  [7],
  [8],
];
