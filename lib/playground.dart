library playground;

import 'package:cuscus/viewmodel/viewmodel.dart' as viewmodel;

void init() => viewmodel.init();

void setup() {

  List<List<viewmodel.CellViewModel>> spreadsheetCells = viewmodel.sheetbooks[0].selectedSheet.cells;
  for (int row = 0; row < inputData.length; row++) {
    for (int col = 0; col < inputData[row].length; col++) {
      spreadsheetCells[row][col].commitFormulaString(inputData[row][col]);
    }
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
  ['Orange', '48', '44', '46'],
  ['Strawberry', '24', '20', '25'],
];
