part of cuscus.viewmodel;

class SpreadsheetEngineViewModel {
  static SpreadsheetEngineViewModel spreadsheet;
  engine.SpreadsheetEngine spreadsheetEngine;

  SpreadsheetEngineViewModel._() {
    spreadsheetEngine = new engine.SpreadsheetEngine();
  }

  static void init() => spreadsheet = new SpreadsheetEngineViewModel._();
  static void clear() => spreadsheet.spreadsheetEngine.clearAll();

  setNode(engine.CellContents newCellContents, engine.CellCoordinates cell) {
    if (newCellContents is engine.EmptyValue) {
      spreadsheetEngine.setNode(cell, new engine.SpreadsheetDepNode(spreadsheetEngine, newCellContents));
      return;
    }
    if (newCellContents is engine.LiteralValue) {
      spreadsheetEngine.setNode(cell, new engine.SpreadsheetDepNode(spreadsheetEngine, newCellContents));
      return;
    }
    if (newCellContents is engine.FormulaValue) {
      var ssDep = new engine.SpreadsheetDepNode(spreadsheetEngine, newCellContents);
      newCellContents.dependants.forEach((coords) {
        engine.SpreadsheetDepNode dep = spreadsheetEngine.cells[coords];
        if (dep == null) { // it's referencing an empty cell
          spreadsheetEngine.setNode(coords, new engine.SpreadsheetDepNode(spreadsheetEngine, new engine.EmptyValue()));
        }
        ssDep.dependants.add(spreadsheetEngine.cells[coords]);
      });
      spreadsheetEngine.setNode(cell, ssDep);
    }
  }

  updateDependencyGraph() => spreadsheetEngine.depGraph.update();

  Map<engine.CellCoordinates, engine.SpreadsheetDepNode> get cells => spreadsheetEngine.cells;

  engine.CellContents resolveSymbols(Map parseTree, int baseSheetId) {
    if (parseTree.keys.first == "text") {
      String cellValue = parseTree["text"];
      if (cellValue.isEmpty) {
        return new engine.EmptyValue();
      }

      engine.LiteralValue literalValue;
      if (cellValue.toLowerCase() == "true" || cellValue.toLowerCase() == "false") {
        literalValue = new engine.LiteralBoolValue(cellValue.toLowerCase() == "true");
      } else {
        try {
          literalValue = new engine.LiteralDoubleValue(int.parse(cellValue).toDouble());
        } catch (e) {
          try {
            literalValue = new engine.LiteralDoubleValue(double.parse(cellValue));
          } catch (ee) {
            literalValue = new engine.LiteralStringValue(cellValue);
          }
        }
      }
      return literalValue;

    } else if (parseTree.keys.first == "formula") {
      engine.CellContents contents = resolveSymbolsRecursive(parseTree["formula"], baseSheetId);
      return new engine.FormulaValue(contents);
    } else {
      throw "Unrecognised parse tree: first key is ${parseTree.keys.first}, should be 'text' or 'formula'";
    }
  }

  engine.CellContents resolveSymbolsRecursive(Map expression, int baseSheetId) {
    assert(expression.length == 1); // the top level map should contain only the type of expression.
    String expressionType = expression.keys.first;
    var expressionContent = expression.values.first;

    switch (expressionType) {
      case "int":
        return new engine.LiteralDoubleValue(int.parse(expressionContent).toDouble());
      case "float":
        return new engine.LiteralDoubleValue(double.parse(expressionContent));
      case "boolean":
        return new engine.LiteralBoolValue(expressionContent == "TRUE");
      case "string":
        return new engine.LiteralStringValue(expressionContent);
      case "binaryOperation":
        String operation = expressionContent["operation"];
        List jsonOperands = expressionContent["operands"];
        return new engine.BinaryOperation(
          operation,
          resolveSymbolsRecursive(jsonOperands[0], baseSheetId),
          resolveSymbolsRecursive(jsonOperands[1], baseSheetId));
      case "unaryOperation":
        String operation = expressionContent["operation"];
        List jsonOperand = expressionContent["operand"];
        return new engine.UnaryOperation(operation, resolveSymbolsRecursive(jsonOperand[0], baseSheetId));
      case "functionCall":
        String functionName = expressionContent["functionName"];
        List jsonArgs = expressionContent["args"];
        List args = [];
        jsonArgs.forEach((arg) {
          var elementsResolvedTree = resolveSymbolsRecursive(arg, baseSheetId);
          args.add(elementsResolvedTree);
        });
        return new engine.FunctionCall(functionName, args);
      case "cellRange":
        // Get the sheet
        SheetViewModel sheet;
        if (expressionContent["sheetName"] == "") {
          sheet = SheetViewModel.sheetWithId(baseSheetId);
        } else {
          sheet = SheetViewModel.sheetWithName(expressionContent["sheetName"]);
        }
        // Get the columns
        int columnStart;
        if (expressionContent["columnStart"] == "") {
          columnStart = -1;
        } else {
          columnStart = sheet.activeColumnNames.indexOf(expressionContent["columnStart"]);
        }
        int columnEnd;
        if (expressionContent["columnEnd"] == "") {
          columnEnd = -1;
        } else {
          columnEnd = sheet.activeColumnNames.indexOf(expressionContent["columnEnd"]);
        }
        // Get the rows
        int rowStart = expressionContent["rowStart"] == "" ? -1 : int.parse(expressionContent["rowStart"]) - 1; // -1 because in the UI, index is from 1, internally index is from 0
        int rowEnd = expressionContent["rowEnd"] == "" ? -1 : int.parse(expressionContent["rowEnd"]) - 1; // -1 because in the UI, index is from 1, internally index is from 0

        if (columnEnd == -1 && rowEnd == -1) { // it's a single cell
          engine.CellCoordinates startCell = new engine.CellCoordinates(rowStart, columnStart, sheet.id);
          return new engine.CellRange.cell(startCell);

        } else if (columnStart != -1 && rowStart != -1 && columnEnd != -1 && rowEnd != -1) { // rectangular range
          engine.CellCoordinates startCell = new engine.CellCoordinates(rowStart, columnStart, sheet.id);
          engine.CellCoordinates endCell = new engine.CellCoordinates(rowEnd, columnEnd, sheet.id);
          return new engine.CellRange.range(startCell, endCell);

        } else { // TODO: all other ranges (column ranges and row ranges)
          throw "TODO: range type not supported yet";
        }
        break;
      default:
        throw "AST error: Unexpected expression type, got $expressionType";
    }
  }

  engine.CellContents makeRelativeCellContents(engine.CellContents cellContentsFrom, engine.CellCoordinates cellFrom, engine.CellCoordinates cellTo) {
    if (cellContentsFrom is engine.EmptyValue) {
      return new engine.EmptyValue();
    }
    if (cellContentsFrom is engine.LiteralValue) {
      return cellContentsFrom.clone();
    }
    if (cellContentsFrom is engine.FormulaValue) {
      engine.CellContents relativeContents = makeRelativeCellContentsRecursive(cellContentsFrom.content, cellFrom, cellTo);
      return new engine.FormulaValue(relativeContents);
    }

    throw "Unknown type of cell contents, got $cellContentsFrom";
  }

  engine.CellContents makeRelativeCellContentsRecursive(engine.CellContents contents, engine.CellCoordinates cellFrom, engine.CellCoordinates cellTo) {
    if (contents is engine.LiteralValue) {
      return contents.clone();
    }
    if (contents is engine.BinaryOperation) {
      return new engine.BinaryOperation(
        contents.operation,
        makeRelativeCellContentsRecursive(contents.lhsOperand, cellFrom, cellTo),
        makeRelativeCellContentsRecursive(contents.rhsOperand, cellFrom, cellTo));
    }
    if (contents is engine.UnaryOperation) {
      return new engine.UnaryOperation(
        contents.operation,
        makeRelativeCellContentsRecursive(contents.operand, cellFrom, cellTo));
    }
    if (contents is engine.FunctionCall) {
      return new engine.FunctionCall(
        contents.functionName,
        contents.args.map((arg) => makeRelativeCellContentsRecursive(arg, cellFrom, cellTo)).toList());
    }
    if (contents is engine.CellRange) {
      int sheetId = contents.sheetId == cellFrom.sheetId ? cellTo.sheetId : contents.sheetId;
      return new engine.CellRange.range(
        new engine.CellCoordinates(contents.topLeftCell.row + cellTo.row - cellFrom.row,
                                    contents.topLeftCell.col + cellTo.col - cellFrom.col,
                                    sheetId),
        new engine.CellCoordinates(contents.bottomRightCell.row + cellTo.row - cellFrom.row,
                                    contents.bottomRightCell.col + cellTo.col - cellFrom.col,
                                    sheetId));
    }
    throw "Unexpected cell contents type, got ${contents.runtimeType}";
  }

  String stringifyFormula(engine.CellContents cellContents, int baseSheetId) {
    if (cellContents == null || cellContents is engine.EmptyValue) {
      return '';
    }
    if (cellContents is engine.LiteralValue) {
      return cellContents.toString();
    }
    if (cellContents is engine.FormulaValue) {
      return "=" + stringifyFormulaComponentRecursive(cellContents.content, baseSheetId);
    }
    throw "Unknown type of cell contents, got $cellContents";
  }

  String stringifyFormulaComponentRecursive(engine.CellContents contents, int baseSheetId) {
    if (contents is engine.LiteralValue) {
      if (contents is engine.LiteralStringValue) {
        return '"${contents}"';
      }
      return contents.toString();
    }
    if (contents is engine.BinaryOperation) {
      String lhsOperandString = stringifyFormulaComponentRecursive(contents.lhsOperand, baseSheetId);
      String rhsOperandString = stringifyFormulaComponentRecursive(contents.rhsOperand, baseSheetId);
      if (operationHasPriorityOver(contents, contents.lhsOperand)) {
        lhsOperandString = "($lhsOperandString)";
      }
      if (operationHasPriorityOver(contents, contents.rhsOperand)) {
        rhsOperandString = "($rhsOperandString)";
      }
      return "$lhsOperandString ${contents.operation} $rhsOperandString";
    }
    if (contents is engine.UnaryOperation) {
      String operandString = stringifyFormulaComponentRecursive(contents.operand, baseSheetId);
      if (operationHasPriorityOver(contents, contents.operand)) {
        operandString = "($operandString)";
      }
      if (contents.operation == "%") { // post-fix
        return "$operandString${contents.operation}";
      } else { // pre-fix
        return "${contents.operation}$operandString";
      }
    }
    if (contents is engine.FunctionCall) {
      String functionName = contents.functionName;
      List<String> newArgs = contents.args.map((arg) => stringifyFormulaComponentRecursive(arg, baseSheetId)).toList();

      String arguments = newArgs.fold('', (prev, arg) => prev == '' ? '$arg' : '$prev, $arg');
      return '${functionName.toUpperCase()}($arguments)';
    }
    if (contents is engine.CellRange) {
      SheetViewModel refSheet = SheetViewModel.sheetWithId(contents.sheetId);

      String sheetRef = '';

      if (contents.sheetId != baseSheetId) {
        sheetRef = "${refSheet.name}!";
      }

      if (contents.isCell) {
        String columnName = refSheet.activeColumnNames[contents.topLeftCell.col];
        return '$sheetRef$columnName${contents.topLeftCell.row + 1}';

      } else {
        String columnNameTopLeft = refSheet.activeColumnNames[contents.topLeftCell.col];
        String columnNameBottomRight = refSheet.activeColumnNames[contents.bottomRightCell.col];
        return '$sheetRef$columnNameTopLeft${contents.topLeftCell.row + 1}:$columnNameBottomRight${contents.bottomRightCell.row + 1}';
      }
    }
    throw "Unknown type of formula, got ${contents.runtimeType}";
  }

  operationHasPriorityOver(engine.CellContents parent, engine.CellContents child) {
    if (child is engine.BinaryOperation && parent is engine.UnaryOperation) {
      return true;
    }
    if (child is engine.BinaryOperation && parent is engine.BinaryOperation) {
      if (parent.operation == "^" && child.operation != "^") {
        return true;
      } else if ((parent.operation == "*" || parent.operation == "/") &&
                  (child.operation != "*" && child.operation != "/" && child.operation != "^")) {
        return true;
      } else if ((parent.operation == "+" || parent.operation == "-") &&
                  (child.operation == "+" && child.operation == "-" && child.operation != "*" && child.operation != "/" && child.operation != "^")) {
        return true;
      } else if ((parent.operation == "&") &&
                  (child.operation != "&" && child.operation == "+" && child.operation == "-" && child.operation != "*" && child.operation != "/" && child.operation != "^")) {
        return true;
      }
    }
    return false;
    }
}
