/**
 * Adds a Spreadsheet style overlay to the dependency graph
 * Based on the initial implementation by @lukechurch in [possum](https://github.com/lukechurch/possum/blob/master/lib/spreadsheet.dart)
 */

import 'dart:async';
import 'dart:math' as math;

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

  clearAll() {
    cells.clear();
    depGraph.nodes.clear();
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

    if (value is EmptyValue) {
      computedValue = value;

    } else if (value is LiteralValue) {
      computedValue = value;

    } else if (value is FormulaValue) {
      computedValue = _evalFormula(value);
    }

    dirty = false;
    changeController.add('Value Changed');
    return;
  }

  LiteralValue _evalFormula(FormulaValue formula) {

    // Look up the values
    Map<CellCoordinates, LiteralValue> coordsToValues = {};
    for (var coords in formula.dependants) {
      coordsToValues[coords] = sheet.cells[coords].computedValue;
    }

    CellContents formulaContent = formula.content;
    if (formulaContent is LiteralValue) {
      return formulaContent;
    }
    if (formulaContent is CellRange) {
      if (formulaContent.isRange) throw "A cell cannot reference a range.";
      return coordsToValues[formulaContent.topLeftCell];
    }
    if (formulaContent is FunctionCallOrOperation) {
      return _evalFunctionCallOrOperation(formulaContent as FunctionCallOrOperation, coordsToValues);
    }

    throw "Function type not supported: ${formula.runtimeType}";
  }

  LiteralValue _evalFunctionCallOrOperation(FunctionCallOrOperation functionCallOrOperation, Map<CellCoordinates, LiteralValue> coordsToValues) {
    List<CellContents> arguments = [];
    List<LiteralValue> evaluatedArguments = [];
    String functionName;

    if (functionCallOrOperation is FunctionCall) {
      arguments = functionCallOrOperation.args;
      functionName = functionCallOrOperation.functionName;
    } else if (functionCallOrOperation is BinaryOperation) {
      arguments = [functionCallOrOperation.lhsOperand, functionCallOrOperation.rhsOperand];
      functionName = binaryOperationToFunctionName(functionCallOrOperation.operation);
    } else if (functionCallOrOperation is UnaryOperation) {
      arguments = [functionCallOrOperation.operand];
      functionName = unaryOperationToFunctionName(functionCallOrOperation.operation);
    } else {
      throw "Function type not supported: ${functionCallOrOperation.runtimeType}";
    }

    for (CellContents arg in arguments) {
      if (arg is LiteralValue) {
        evaluatedArguments.add(arg);
      } else if (arg is CellRange) {
        evaluatedArguments.addAll(arg.cellsList.map((cellCoords) => coordsToValues[cellCoords]));
      } else if (arg is FunctionCallOrOperation) {
        evaluatedArguments.add(_evalFunctionCallOrOperation(arg as FunctionCallOrOperation, coordsToValues));
      } else {
        throw "Function type not supported: ${arg.runtimeType}";
      }
    }
    return evalSimpleFunctionCall(functionName, evaluatedArguments);
  }
}

abstract class CellContents {
  CellContents clone();
}

abstract class LiteralValue extends CellContents {
  var value;
  String toString() => "$value";
}

class LiteralDoubleValue extends LiteralValue {
  LiteralDoubleValue(double v) {
    value = v;
  }
  LiteralDoubleValue clone() => new LiteralDoubleValue(value);
  String toString() => (value is int) ? value.toString() : value.toStringAsFixed(2);
}

class LiteralStringValue extends LiteralValue {
  LiteralStringValue(String v) {
    value = v;
  }
  LiteralStringValue clone() => new LiteralStringValue(value);
}

class LiteralBoolValue extends LiteralValue {
  LiteralBoolValue(bool v) {
    value = v;
  }
  LiteralBoolValue clone() => new LiteralBoolValue(value);
}

class EmptyValue extends LiteralValue {
  EmptyValue() {
    value = '';
  }
  EmptyValue clone() => new EmptyValue();
}

class CellRange extends CellContents {
  CellCoordinates topLeftCell;
  bool topLeftCellAnchoredRow;
  bool topLeftCellAnchoredCol;
  CellCoordinates bottomRightCell;
  bool bottomRightCellAnchoredRow;
  bool bottomRightCellAnchoredCol;

  CellRange.cell(CellCoordinates cell, bool anchoredRow, bool anchoredCol) {
    topLeftCell = bottomRightCell = cell;
    topLeftCellAnchoredRow = bottomRightCellAnchoredRow = anchoredRow;
    topLeftCellAnchoredCol = bottomRightCellAnchoredCol = anchoredCol;
  }

  CellRange.range(CellCoordinates corner1, CellCoordinates corner2,
                  bool corner1AnchoredRow, bool corner1AnchoredCol,
                  bool corner2AnchoredRow, bool corner2AnchoredCol) {
    if (corner1.sheetId != corner2.sheetId) {
      throw "Ranges over multiple sheets unsupported!";
    }
    int topLeftRow = math.min(corner1.row, corner2.row);
    int topLeftCol = math.min(corner1.col, corner2.col);
    topLeftCell = new CellCoordinates(topLeftRow, topLeftCol, corner1.sheetId);
    topLeftCellAnchoredRow = topLeftRow == corner1.row ? corner1AnchoredRow : corner2AnchoredRow;
    topLeftCellAnchoredCol = topLeftCol == corner1.col ? corner1AnchoredCol : corner2AnchoredCol;

    int bottomRightRow = math.max(corner1.row, corner2.row);
    int bottomRightCol = math.max(corner1.col, corner2.col);
    bottomRightCell = new CellCoordinates(bottomRightRow, bottomRightCol, corner1.sheetId);
    bottomRightCellAnchoredRow = bottomRightRow == corner1.row ? corner1AnchoredRow : corner2AnchoredRow;
    bottomRightCellAnchoredCol = bottomRightCol == corner1.col ? corner1AnchoredCol : corner2AnchoredCol;
  }

  clone() => new CellRange.range(topLeftCell, bottomRightCell,
                                 topLeftCellAnchoredRow, topLeftCellAnchoredCol,
                                 bottomRightCellAnchoredRow, bottomRightCellAnchoredCol);

  int get sheetId => topLeftCell.sheetId;
  bool get isCell => topLeftCell == bottomRightCell;
  bool get isRange => topLeftCell != bottomRightCell;

  /// Turns a range of cells into a list of cells.
  List<CellCoordinates> get cellsList {
    List<CellCoordinates> cellList = [];
    for (int row = topLeftCell.row; row <= bottomRightCell.row; row++) {
      for (int col = topLeftCell.col; col <= bottomRightCell.col; col++) {
        CellCoordinates cell = new CellCoordinates(row, col, sheetId);
        spreadsheetEngine.cells[cell] = new SpreadsheetDepNode(spreadsheetEngine, new EmptyValue());
        cellList.add(cell);
      }
    }
    return cellList;
  }

  String toString() {
    return '$sheetId (col: ${topLeftCell.col}, row: ${topLeftCell.row}) - (col: ${bottomRightCell.col}, row: ${bottomRightCell.row})';
  }
}

class FormulaValue extends CellContents {
  CellContents content;
  List<CellCoordinates> dependants = [];

  FormulaValue(this.content) {
    dependants = getDependantsRecursive(content);
  }

  List<CellCoordinates> getDependantsRecursive(CellContents contents) {
    if (contents is LiteralValue) {
      return [];
    }
    if (contents is CellRange) {
      return contents.cellsList;
    }
    if (contents is FunctionCall) {
      List<CellCoordinates> deps = [];
      contents.args.forEach((CellContents cell) => deps.addAll(getDependantsRecursive(cell)));
      return deps;
    }
    if (contents is BinaryOperation) {
      List<CellCoordinates> deps = [];
      deps.addAll(getDependantsRecursive(contents.lhsOperand));
      deps.addAll(getDependantsRecursive(contents.rhsOperand));
      return deps;
    }
    if (contents is UnaryOperation) {
      return getDependantsRecursive(contents.operand);
    }
    throw "Unexpected Cell contents, got $contents";
  }

  toString() => "Formula: $content";

  FormulaValue clone() => new FormulaValue(content.clone());
}

class FunctionCallOrOperation {}

class FunctionCall extends CellContents implements FunctionCallOrOperation {
  String functionName;
  List<CellContents> args;
  FunctionCall(this.functionName, this.args);
  FunctionCall clone() => new FunctionCall(functionName, args.map((arg) => arg.clone()).toList());
  toString() => "$functionName$args";
}

class BinaryOperation extends CellContents implements FunctionCallOrOperation {
  String operation;
  CellContents lhsOperand;
  CellContents rhsOperand;
  BinaryOperation(this.operation, this.lhsOperand, this.rhsOperand);
  BinaryOperation clone() => new BinaryOperation(operation, lhsOperand.clone(), rhsOperand.clone());
  toString() => "$operation($lhsOperand, $rhsOperand)";
}

class UnaryOperation extends CellContents implements FunctionCallOrOperation {
  String operation;
  CellContents operand;
  UnaryOperation(this.operation, this.operand);
  UnaryOperation clone() => new UnaryOperation(operation, operand.clone());
  toString() => "$operation($operand)";
}

class CellCoordinates {
  final int row;
  final int col;
  final int sheetId;

  CellCoordinates(this.row, this.col, this.sheetId);
  toString() => "$sheetId!R${row}C${col}";

  bool operator ==(Object other) {
    return
      other is CellCoordinates &&
      row == other.row &&
      col == other.col &&
      sheetId == other.sheetId;
  }

  // hash code implementation from Josh Bloch's Effective Java, Item 8 (second edition)
  int get hashCode {
    int result = 7;
    result = 37 * result + row;
    result = 37 * result + col;
    result = 37 * result + sheetId;
    return result;
  }
}

String binaryOperationToFunctionName(String operation) {
  switch (operation) {
    case "=":
      return "eq";
    case "<>":
      return "neq";
    case "<":
      return "lt";
    case ">":
      return "gt";
    case "<=":
      return "le";
    case ">=":
      return "ge";
    case "&":
      return "concat";
    case "+":
      return "add";
    case "-":
      return "sub";
    case "*":
      return "mul";
    case "/":
      return "div";
    case "^":
      return "pow";
    case "%":
      return "percent";
  }
  throw "Operation unsupported, got $operation";
}

String unaryOperationToFunctionName(String operation) {
  switch (operation) {
    case "-":
      return "umin";
    case "+":
      return "uplus";
  }
  throw 'Unary operation unsupported, got $operation';
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
    case "rad":
      return i_rad(values[0]);
    case "deg":
      return i_deg(values[0]);
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
    case "if":
      return i_if(values[0], values[1], values[2]);
    case "random":
      return i_random();
    case "median":
      return i_median(values);
    case "quartile":
      return i_quartile(values);
  }
  throw "Function name not supported: $functionName";
}
