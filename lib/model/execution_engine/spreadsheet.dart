/**
 * Adds a Spreadsheet style overlay to the dependency graph
 * Based on the initial implementation by @lukechurch in [possum](https://github.com/lukechurch/possum/blob/master/lib/spreadsheet.dart)
 */

import 'dart:async';

import 'package:possum/deps_map.dart';

import 'intrinsics.dart';

SpreadsheetEngine spreadsheetEngine = new SpreadsheetEngine();

class SpreadsheetEngine {
  Map<CellCoordinates, SpreadsheetDepNode> cells = {};
  DepGraph depGraph = new DepGraph();

  toString() {
    StringBuffer sb = new StringBuffer();
    cells.forEach((k, v) => sb.writeln("$k: ${v.value} ${v.computedValue} ${v.dirty}"));
    return sb.toString();
  }

  // The node should have correct dependants
  // This function will fix up the node that is being
  // removed
  setNode(CellCoordinates coords, SpreadsheetDepNode node) {
    if (node.dependees.length > 0) throw "Don't set dependees on nodes before adding them";

    SpreadsheetDepNode existingNode = cells[coords];

    // Remove existing node
    if (existingNode != null) {
      depGraph.nodes.remove(existingNode);

      // Remove the existing node from the graph and add the new one.
      for (var dpNode in existingNode.dependees) {
        dpNode.dependants..remove(existingNode)..add(node);
        node.dependees.add(dpNode);
      }
      for (var dpNode in existingNode.dependants) {
        dpNode.dependees.remove(existingNode);
      }
    }

    depGraph.nodes.add(node);

    for (var dependant in node.dependants) {
      dependant.dependees.add(node);
    }
    cells[coords] = node;

    depGraph.setDirtyAndPropagate(node);

    if (existingNode != null) {
      // Notify the view model that the node has been changed and that they should subscribe to the new node.
      existingNode.changeController.close();
    }
  }

  clear(CellCoordinates coords) {
    SpreadsheetDepNode existingNode = cells[coords];

    // Remove existing node
    if (existingNode != null) {
      depGraph.nodes.remove(existingNode);

      // Remove the existing node from the graph and add the new one.
      for (var dpNode in existingNode.dependees) {
        dpNode.dependants.remove(existingNode);
      }
      for (var dpNode in existingNode.dependants) {
        dpNode.dependees.remove(existingNode);
      }

      // Notify the view model that the node has been changed and that they should subscribe to the new node.
      existingNode.changeController.close();
    }

    cells.remove(coords);
  }

  /// Turns a range of cells into a list of cells.
  List<CellCoordinates> getCellsBetween(CellCoordinates topLeft, CellCoordinates bottomRight) {
    if (topLeft.sheetId != bottomRight.sheetId) {
      throw "Ranges across sheets not supported!";
    }

    List<List<CellCoordinates>> cellMatrix = [];
    for (int row = topLeft.row; row <= bottomRight.row; row++) {
      cellMatrix.add(new List(bottomRight.col - topLeft.col + 1));
    }

    for (CellCoordinates cell in spreadsheetEngine.cells.keys.where((CellCoordinates loc) => loc is CellCoordinates)) {
      if (cell.sheetId == topLeft.sheetId &&
          topLeft.row <= cell.row && cell.row <= bottomRight.row &&
          topLeft.col <= cell.col && cell.col <= bottomRight.col) {
        cellMatrix[cell.row - topLeft.row][cell.col - topLeft.col] = cell;
      }
    }

    for (int row = topLeft.row; row <= bottomRight.row; row++) {
      for (int col = topLeft.col; col <= bottomRight.col; col++) {
        if (cellMatrix[row - topLeft.row][col - topLeft.col] == null) {
          CellCoordinates cell = new CellCoordinates(row, col, topLeft.sheetId);
          cellMatrix[row - topLeft.row][col - topLeft.col] = cell;
          spreadsheetEngine.cells[cell] = new SpreadsheetDepNode(spreadsheetEngine, new EmptyValue());
        }
      }
    }
    return cellMatrix.fold([], (List<CellCoordinates> cellList, List<CellCoordinates> row) => cellList..addAll(row));
  }
}

class SpreadsheetDepNode extends DepNode<CellContents> {
  SpreadsheetEngine sheet;
  LiteralValue computedValue;

  StreamController changeController = new StreamController<String>.broadcast();
  Stream<String> get onChange => changeController.stream;
  Future get whenDone => changeController.done;

  SpreadsheetDepNode(this.sheet, CellContents fc) : super(fc);

  eval() {
    if (!this.dirty) {
      print ("Invariant violated: executing clean cell");
    }

    // TODO: this is a hack. Should be replaced with expected types for the dependants of a function call, and then a switch here creating the appropriate [LiteralValue]
    if (value is EmptyValue) {
      computedValue = new LiteralDoubleValue(0.0);

    } else if (value is LiteralValue) {
      computedValue = value;

    } else if (value is FunctionCall) {
      var functionCall = value as FunctionCall;

      // Look up the values
      Map<CellCoordinates, LiteralValue> coordsValues = {};
      for (var coords in functionCall.dependants) {
        coordsValues[coords] = sheet.cells[coords].computedValue;
      }

      computedValue = evalFunctionCall(functionCall.ast, coordsValues);
    }

    dirty = false;
    changeController.add('Value Changed');
    return;
  }
}

abstract class CellContents {
  CellContents clone();
}

abstract class LiteralValue extends CellContents {
  var value;
  toString() => "$value";
}

class LiteralDoubleValue extends LiteralValue {
  double value;
  LiteralDoubleValue(this.value);
  LiteralDoubleValue clone() => new LiteralDoubleValue(value);
  toString() => (value is int) ? value.toString() : value.toStringAsFixed(2);
}

class LiteralStringValue extends LiteralValue {
  String value;
  LiteralStringValue(this.value);
  LiteralStringValue clone() => new LiteralStringValue(value);
}

class LiteralBoolValue extends LiteralValue {
  bool value;
  LiteralBoolValue(this.value);
  LiteralBoolValue clone() => new LiteralBoolValue(value);
}

class EmptyValue extends CellContents {
  final String stringValue = '';
  final double doubleValue = 0.0;
  toString() => "<EMPTY>";
  EmptyValue clone() => new EmptyValue();
}

class FunctionCall extends CellContents {
  Map ast;
  List<CellCoordinates> dependants = [];

  FunctionCall(this.ast, this.dependants) { }
  toString() => "$ast";
  FunctionCall clone() {
    Map astClone = cloneAst(ast);
    List<CellCoordinates> dependantsClone = new List.from(dependants);
    return new FunctionCall(astClone, dependantsClone);
  }

  cloneAst(Map ast) {
    Map newAst = {};
    String expressionType = ast.keys.first;
    var expressionValue = ast.values.first;
    switch (expressionType) {
      case "literal":
        newAst = {"literal": (expressionValue as LiteralValue).clone()};
        break;
      case "funcCall":
        String functionName = expressionValue["functionName"];
        List args = expressionValue["args"];
        List newArgs = [];
        args.forEach((Map arg) => newArgs.add(cloneAst(arg)));
        newAst = {"funcCall": {"functionName": functionName, "args": newArgs}};
        break;
      case "cell-ref":
        newAst = {"cell-ref": expressionValue};
        break;
    }
    return newAst;
  }
}

class CellCoordinates {
  final int row;
  final int col;
  final int sheetId;

  CellCoordinates(this.row, this.col, this.sheetId);
  toString() => "$sheetId!R${row}C${col}";

  bool operator ==(CellCoordinates other) {
    return row == other.row && col == other.col && sheetId == other.sheetId;
  }

  int get hashCode => 10000000 * sheetId + 10000 * row + col; // TODO: Fix dumb hashcode
}

LiteralValue evalFunctionCall(Map function, Map<CellCoordinates, LiteralValue> coordsValues) {
  assert(function.length == 1);
  String functionType = function.keys.first;
  var functionContent = function.values.first;

  switch(functionType) {
    case "literal":
      assert(functionContent is LiteralValue);
      return functionContent;
    case "cell-ref":
      assert(functionContent is CellCoordinates);
      return coordsValues[functionContent];
    case "funcCall":
      String functionName = functionContent["functionName"];
      List<LiteralValue> arguments = (functionContent["args"] as List).map((Map arg) => evalFunctionCall(arg, coordsValues)).toList();
      return evalSimpleFunctionCall(functionName, arguments);
  }
  throw "Function type not supported: $functionType";
}

LiteralValue evalSimpleFunctionCall(String functionName, List<LiteralValue> values) {
  switch (functionName) {
    case "eq":
      return i_eq(values[0], values[1]);
    case "neq":
      return i_neq(values[0], values[1]);
    case "lt":
      return i_lt(values[0], values[1]);
    case "gt":
      return i_gt(values[0], values[1]);
    case "le":
      return i_le(values[0], values[1]);
    case "ge":
      return i_ge(values[0], values[1]);
    case "concat":
      return i_concat(values[0], values[1]);
    case "add":
      return i_add(values[0], values[1]);
    case "sub":
      return i_sub(values[0], values[1]);
    case "mul":
      return i_mul(values[0], values[1]);
    case "div":
      return i_div(values[0], values[1]);
    case "pow":
      return i_pow(values[0], values[1]);
    case "percent":
      return i_percent(values[0]);
    case "umin":
      return i_umin(values[0]);
    case "uplus":
      return i_uplus(values[0]);
    case "sin":
      return i_sin(values[0]);
    case "cos":
      return i_cos(values[0]);
    case "tan":
      return i_tan(values[0]);
    case "cot":
      return i_cot(values[0]);
    case "asin":
      return i_asin(values[0]);
    case "acos":
      return i_acos(values[0]);
    case "atan":
      return i_percent(values[0]);
    case "atan2":
      return i_atan2(values[0], values[1]);
    case "acot":
      return i_acot(values[0]);
    case "abs":
      return i_abs(values[0]);
    case "ceiling":
      return i_ceiling(values[0]);
    case "exp":
      return i_exp(values[0]);
    case "floor":
      return i_floor(values[0]);
    case "fact":
      return i_fact(values[0]);
    case "int":
      return i_int(values[0]);
    case "isEven":
      return i_isEven(values[0]);
    case "isOdd":
      return i_isOdd(values[0]);
    case "ln":
      return i_ln(values[0]);
    case "mod":
      return i_mod(values[0], values[1]);
    case "power":
      return i_power(values[0], values[1]);
    case "radians":
      return i_radians(values[0]);
    case "round":
      return i_round(values[0]);
    case "trunc":
      return i_trunc(values[0]);
    case "sign":
      return i_sign(values[0]);
    case "sqrt":
      return i_sqrt(values[0]);
    case "and":
      return i_and(values[0], values[1]);
    case "or":
      return i_or(values[0], values[1]);
    case "xor":
      return i_xor(values[0], values[1]);
    case "average":
      return i_average(values);
    case "max":
      return i_max(values);
    case "min":
      return i_min(values);
    case "sum":
      return i_sum(values);
    case "product":
      return i_product(values);
  }
  throw "Function name not supported: $functionName";
}
