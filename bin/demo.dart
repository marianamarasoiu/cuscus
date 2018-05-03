/**
 * Demonstrates usage of the spreadsheet and dependency API.
 * * Based on the initial implementation by @lukechurch in [possum](https://github.com/marianamarasoiu/possum/blob/master/bin/demo.dart)
 */
import 'package:cuscus/model/execution_engine/spreadsheet.dart';

main() {
  SpreadsheetEngine ss = new SpreadsheetEngine();
  ss.setNode(new CellCoordinates(0, 0, 0), new SpreadsheetDep(ss, new LiteralDoubleValue(41.0)));
  ss.setNode(new CellCoordinates(0, 1, 0), new SpreadsheetDep(ss, new LiteralDoubleValue(1.0)));
  
  var arguments = [
    new CellCoordinates(0, 0, 0),
    new CellCoordinates(0, 1, 0)
  ];

  {
    Map formulaAst = {"funcCall": {"functionName": "gt", "args": [{"cell-ref": new CellCoordinates(0, 0, 0)}, {"cell-ref": new CellCoordinates(0, 1, 0)}]}};
    var ssDep = new SpreadsheetDep(ss, new FunctionCall(formulaAst, arguments));
    ssDep.dependants.addAll(arguments.map((location) => ss.cells[location]));
    ss.setNode(new CellCoordinates(1, 0, 0), ssDep);
  }

  print(ss);
  ss.depGraph.update();
  print(ss);

  ss.setNode(new CellCoordinates(0, 2, 0), new SpreadsheetDep(ss, new LiteralDoubleValue(5.0)));
  
  arguments = [
    new CellCoordinates(0, 0, 0),
    new CellCoordinates(0, 1, 0),
    new CellCoordinates(0, 2, 0)
  ];

  {
    Map formulaAst = {
      "funcCall": {
        "functionName": "sub",
        "args": [
          {
            "funcCall": {
              "functionName": "add",
              "args": [{"cell-ref": new CellCoordinates(0, 0, 0)}, {"cell-ref": new CellCoordinates(0, 1, 0)}]
            },
          },
          {"cell-ref": new CellCoordinates(0, 2, 0)}
        ]
      }};
    var ssDep = new SpreadsheetDep(ss, new FunctionCall(formulaAst, arguments));
    ssDep.dependants.addAll(arguments.map((location) => ss.cells[location]));
    ss.setNode(new CellCoordinates(1, 2, 0), ssDep);
  }

  print(ss);
  ss.depGraph.update();
  print(ss);

  arguments = [
  ];

  {
    Map formulaAst = {
      "funcCall": {
        "functionName": "add",
        "args": [{"literal": new LiteralDoubleValue(34.0)}, {"literal": new LiteralDoubleValue(12.0)}]}
      };
    var ssDep = new SpreadsheetDep(ss, new FunctionCall(formulaAst, arguments));
    ssDep.dependants.addAll(arguments.map((location) => ss.cells[location]));
    ss.setNode(new CellCoordinates(1, 3, 0), ssDep);
  }

  print(ss);
  ss.depGraph.update();
  print(ss);

  arguments = [
    new CellCoordinates(0, 0, 0),
    new CellCoordinates(0, 1, 0),
    new CellCoordinates(0, 2, 0)
  ];

  {
    Map formulaAst = {"funcCall": {"functionName": "sum", "args": [{"cell-ref": new CellCoordinates(0, 0, 0)}, {"cell-ref": new CellCoordinates(0, 1, 0)}, {"cell-ref": new CellCoordinates(0, 2, 0)}]}};
    var ssDep = new SpreadsheetDep(ss, new FunctionCall(formulaAst, arguments));
    ssDep.dependants.addAll(arguments.map((location) => ss.cells[location]));
    ss.setNode(new CellCoordinates(1, 4, 0), ssDep);
  }

  print(ss);
  ss.depGraph.update();
  print(ss);
}
