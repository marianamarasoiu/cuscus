library playground;

import 'dart:html';

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
    spreadsheetCells[0][3].commitFormulaString('Max stock');
    spreadsheetCells[0][4].commitFormulaString('Min stock');
    for (int row = 0; row < otherData.length; row++) {
      spreadsheetCells[row+1][2].commitFormulaString('=Average(Sheet1!B${row+2}:Sheet1!D${row+2})');
      spreadsheetCells[row+1][3].commitFormulaString('=Max(Sheet1!B${row+2}:Sheet1!D${row+2})');
      spreadsheetCells[row+1][4].commitFormulaString('=Min(Sheet1!B${row+2}:Sheet1!D${row+2})');
    }
  }

  {
    viewmodel.LayerSheetFactory layerSheetFactory = new viewmodel.LayerSheetFactory(viewmodel.Shape.rect);
    viewmodel.GraphicsSheetViewModel sheet = layerSheetFactory.sheet;
    viewmodel.LayerViewModel layer = layerSheetFactory.layer;

    layer.addShape(0, {
      viewmodel.Rect.x: 500,
      viewmodel.Rect.y: 100,
      viewmodel.Rect.width: 30,
      viewmodel.Rect.height: 100});
    sheet.updateRow(0);
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.height])].commitFormulaString('=Sheet2!C2 * 5');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.x])].commitFormulaString('=500 + Sheet2!A2 * 50');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.y])].commitFormulaString('=300 - Height1');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.fillColor])].commitFormulaString('#efc45f');

    sheet.cells[1][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.width])].commitFormulaString('30');
    sheet.cells[2][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.width])].commitFormulaString('30');
    sheet.cells[3][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.width])].commitFormulaString('30');
    sheet.cells[4][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.width])].commitFormulaString('30');
    sheet.cells[5][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.width])].commitFormulaString('30');
    sheet.cells[6][sheet.activeColumnNames.indexOf(viewmodel.rectPropertyToColumnName[viewmodel.Rect.width])].commitFormulaString('30');

    sheet.name = 'Bars';
    querySelector('#sheetbook${sheet.sheetbookViewModel.id}-label${sheet.id}').text = sheet.name;
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

    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.x1])].commitFormulaString('=Bars!X1 + Bars!Width1 / 2');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.x2])].commitFormulaString('=StartX1');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.y1])].commitFormulaString('=300 - Sheet2!D2 * 5');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.y2])].commitFormulaString('=300 - Sheet2!E2 * 5');
    sheet.cells[0][sheet.activeColumnNames.indexOf(viewmodel.linePropertyToColumnName[viewmodel.Line.strokeWidth])].commitFormulaString('2');

    sheet.name = 'Lines';
    querySelector('#sheetbook${sheet.sheetbookViewModel.id}-label${sheet.id}').text = sheet.name;
  }

  viewmodel.sheetbooks[0].selectedSheet.name = 'DataSheet1';
  querySelector('#sheetbook${viewmodel.sheetbooks[0].id}-label${viewmodel.sheetbooks[0].selectedSheet.id}').text = viewmodel.sheetbooks[0].selectedSheet.name;
  viewmodel.sheetbooks[1].selectedSheet.name = 'DataSheet2';
  querySelector('#sheetbook${viewmodel.sheetbooks[1].id}-label${viewmodel.sheetbooks[1].selectedSheet.id}').text = viewmodel.sheetbooks[1].selectedSheet.name;
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
