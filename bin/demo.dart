/**
 * Demonstrates usage of the spreadsheet and dependency API.
 * * Based on the initial implementation by @lukechurch in [possum](https://github.com/marianamarasoiu/possum/blob/master/bin/demo.dart)
 */
import 'package:cuscus/model/execution_engine/spreadsheet.dart';

main() {
  SpreadsheetEngine ss = new SpreadsheetEngine();
  ss.setNode(new CellCoordinates(0, 0, 0), new SpreadsheetDepNode(ss, new LiteralDoubleValue(41.0)));
  ss.setNode(new CellCoordinates(0, 1, 0), new SpreadsheetDepNode(ss, new LiteralDoubleValue(1.0)));

  {
    FormulaValue formula = new FormulaValue(new FunctionCall("gt", [new CellRange.cell(new CellCoordinates(0, 0, 0), false, false), new CellRange.cell(new CellCoordinates(0, 1, 0), false, false)]));
    var ssDep = new SpreadsheetDepNode(ss, formula);
    ssDep.dependants.addAll(formula.dependants.map((location) => ss.cells[location]));
    ss.setNode(new CellCoordinates(1, 0, 0), ssDep);
  }

  print(ss);
  ss.depGraph.update();
  print(ss);

  ss.setNode(new CellCoordinates(0, 2, 0), new SpreadsheetDepNode(ss, new LiteralDoubleValue(5.0)));

  {
    FormulaValue formula = new FormulaValue(
      new FunctionCall("sub", [
        new FunctionCall("add", [new CellRange.cell(new CellCoordinates(0, 0, 0), false, false), new CellRange.cell(new CellCoordinates(0, 1, 0), false, false)]),
        new CellRange.cell(new CellCoordinates(0, 2, 0), false, false)])
    );
    var ssDep = new SpreadsheetDepNode(ss, formula);
    ssDep.dependants.addAll(formula.dependants.map((location) => ss.cells[location]));
    ss.setNode(new CellCoordinates(1, 2, 0), ssDep);
  }

  print(ss);
  ss.depGraph.update();
  print(ss);

  {
    FormulaValue formula = new FormulaValue(
      new FunctionCall("add", [
        new LiteralDoubleValue(34.0),
        new LiteralDoubleValue(12.0)])
    );
    var ssDep = new SpreadsheetDepNode(ss, formula);
    ssDep.dependants.addAll(formula.dependants.map((location) => ss.cells[location]));
    ss.setNode(new CellCoordinates(1, 3, 0), ssDep);
  }

  print(ss);
  ss.depGraph.update();
  print(ss);

  {
    FormulaValue formula = new FormulaValue(
      new FunctionCall("sum", [
        new CellRange.cell(new CellCoordinates(0, 0, 0), false, false),
        new CellRange.cell(new CellCoordinates(0, 1, 0), false, false),
        new CellRange.cell(new CellCoordinates(0, 2, 0), false, false)])
    );
    var ssDep = new SpreadsheetDepNode(ss, formula);
    ssDep.dependants.addAll(formula.dependants.map((location) => ss.cells[location]));
    ss.setNode(new CellCoordinates(1, 4, 0), ssDep);
  }

  print(ss);
  ss.depGraph.update();
  print(ss);
}
