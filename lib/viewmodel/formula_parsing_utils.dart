part of cuscus.viewmodel;

void addNodeToSpreadsheetEngine(engine.CellContents newCellContents, engine.CellCoordinates cell, engine.SpreadsheetEngine sse) {
  if (newCellContents is engine.EmptyValue) {
    sse.setNode(cell, new engine.SpreadsheetDepNode(sse, newCellContents));
    return;
  }
  if (newCellContents is engine.LiteralValue) {
    sse.setNode(cell, new engine.SpreadsheetDepNode(sse, newCellContents));
    return;
  }
  if (newCellContents is engine.FunctionCall) {
    var ssDep = new engine.SpreadsheetDepNode(sse, newCellContents);
    newCellContents.dependants.forEach((coords) {
      engine.SpreadsheetDepNode dep = sse.cells[coords];
      if (dep == null) { // it's referencing an empty cell
        sse.setNode(coords, new engine.SpreadsheetDepNode(sse, new engine.EmptyValue()));
      }
      ssDep.dependants.add(sse.cells[coords]);
    });
    sse.setNode(cell, ssDep);
  }
}

List<engine.CellCoordinates> getDependants(Map elementsResolvedTree) {
  String expressionType = elementsResolvedTree.keys.first;
  List<engine.CellCoordinates> dependants = [];

  switch (expressionType) {
    case "literal":
      // do nothing, it's a literal, not a cell dependency.
      break;
    case "cell-ref":
      dependants.add(elementsResolvedTree[expressionType]);
      break;
    case "funcCall":
      List args = elementsResolvedTree[expressionType]["args"];
      args.forEach((Map arg) {
        dependants.addAll(getDependants(arg));
      });
  }
  return dependants;
}

engine.CellContents resolveSymbols(Map parseTree, int baseSheetId, engine.SpreadsheetEngine ss) {
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
    Map elementsResolvedTree = resolveSymbolsRecursive(parseTree["formula"], baseSheetId, ss);
    List dependants = getDependants(elementsResolvedTree);
    return new engine.FunctionCall(elementsResolvedTree, dependants);
  } else {
    throw "Unrecognised parse tree: first key is ${parseTree.keys.first}, should be 'text' or 'formula'";
  }
}

Map resolveSymbolsRecursive(Map expression, int baseSheetId, engine.SpreadsheetEngine ss) {
  assert(expression.length == 1); // the top level map should contain only the type of expression.
  String expressionType = expression.keys.first;
  var newExpression;

  switch (expressionType) {
    case "int":
      newExpression = {"literal": new engine.LiteralDoubleValue(int.parse(expression["int"]).toDouble())};
      break;
    case "float":
      newExpression = {"literal": new engine.LiteralDoubleValue(double.parse(expression["float"]))};
      break;
    case "boolean":
      newExpression = {"literal": new engine.LiteralBoolValue(expression["boolean"] == "TRUE")};
      break;
    case "string":
      newExpression = {"literal": new engine.LiteralStringValue(expression["string"])};
      break;
    case "funcCall":
      String functionName = expression["funcCall"]["functionName"];
      List jsonArgs = expression["funcCall"]["args"];
      List args = [];
      jsonArgs.forEach((Map arg) {
        var elementsResolvedTree = resolveSymbolsRecursive(arg, baseSheetId, ss);
        if (elementsResolvedTree is List) { // if list, then it's a list of cells coming from a range, and should be listed as arguments
          args.addAll(elementsResolvedTree);
        } else {
          args.add(elementsResolvedTree);
        }
      });
      newExpression = {"funcCall": {"functionName": functionName, "args": args}};
      break;
    case "range":
      Map expressionContent = expression["range"];
      // Get the sheet
      SheetViewModel sheet;
      if (expressionContent["sheetName"] == "") {
        sheet = sheets.singleWhere((s) => s.id == baseSheetId);
      } else {
        sheet = sheets.singleWhere((s) => s.name == expressionContent["sheetName"]);
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
        newExpression = {"cell-ref": new engine.CellCoordinates(rowStart, columnStart, sheet.id)};
      } else if (columnStart != -1 && rowStart != -1 && columnEnd != -1 && rowEnd != -1) { // rectangular range
        List<engine.CellCoordinates> cells = ss.getCellsBetween(new engine.CellCoordinates(rowStart, columnStart, sheet.id), new engine.CellCoordinates(rowEnd, columnEnd, sheet.id));
        newExpression = [];
        cells.forEach((cell) {
          newExpression.add({"cell-ref": cell});
        });
      } else { // TODO: all other ranges (column ranges and row ranges)
        throw "TODO: range type not supported yet";
      }
      break;
  }

  return newExpression;
}

engine.CellContents cloneElementsResolvedTree(engine.CellContents cellContents) {
  if (cellContents is engine.EmptyValue) {
    return new engine.EmptyValue();
  }
  if (cellContents is engine.LiteralValue) {
    return cellContents.clone();
  }
  if (cellContents is engine.FunctionCall) {
    return cellContents.clone();
  }

  throw "Unknown type of cell contents, got $cellContents";
}

engine.CellContents makeRelativeCellContents(engine.CellContents cellContentsFrom, engine.CellCoordinates cellFrom, engine.CellCoordinates cellTo, engine.SpreadsheetEngine sse) {
  if (cellContentsFrom is engine.EmptyValue) {
    return new engine.EmptyValue();
  }
  if (cellContentsFrom is engine.LiteralValue) {
    return cellContentsFrom.clone();
  }
  if (cellContentsFrom is engine.FunctionCall) {
    Map relativeAst = makeRelativeAstRecursive(cellContentsFrom.ast, cellFrom, cellTo);
    List dependants = getDependants(relativeAst);
    return new engine.FunctionCall(relativeAst, dependants);
  }

  throw "Unknown type of cell contents, got $cellContentsFrom";
}

Map makeRelativeAstRecursive(Map ast, engine.CellCoordinates cellFrom, engine.CellCoordinates cellTo) {
  Map newAst = {};
  String expressionType = ast.keys.first;
  var expressionValue = ast.values.first;
  switch (expressionType) {
    case "literal":
      newAst = {"literal": (expressionValue as engine.LiteralValue).clone()};
      break;
    case "funcCall":
      String functionName = expressionValue["functionName"];
      List args = expressionValue["args"];
      List newArgs = [];
      args.forEach((Map arg) => newArgs.add(makeRelativeAstRecursive(arg, cellFrom, cellTo)));
      newAst = {"funcCall": {"functionName": functionName, "args": newArgs}};
      break;
    case "cell-ref":
      engine.CellCoordinates oldCellRef = expressionValue;
      engine.CellCoordinates newCellRef = new engine.CellCoordinates(
        oldCellRef.row + cellTo.row - cellFrom.row,
        oldCellRef.col + cellTo.col - cellFrom.col,
        oldCellRef.sheetId == cellFrom.sheetId ? cellTo.sheetId : oldCellRef.sheetId);
      newAst = {"cell-ref": newCellRef};
      break;
  }
  return newAst;
}

String stringifyFormula(engine.CellContents cellContents, int baseSheetId, engine.SpreadsheetEngine ss) {
  if (cellContents is engine.EmptyValue) {
    return '';
  }
  if (cellContents is engine.LiteralValue) {
    return cellContents.toString();
  }
  if (cellContents is engine.FunctionCall) {
    return "=" + stringifyFormulaRecursive(cellContents.ast, baseSheetId, ss);
  }
  throw "Unknown type of cell contents, got $cellContents";
}

String stringifyFormulaRecursive(Map ast, int baseSheetId, engine.SpreadsheetEngine ss) {
  String expressionType = ast.keys.first;
  var expressionValue = ast.keys.first;
  switch (expressionType) {
    case "literal":
      return expressionValue.toString();
    case "funcCall":
      String functionName = expressionValue["functionName"];
      List args = expressionValue["args"];
      List<String> newArgs = [];
      args.forEach((Map arg) => newArgs.add(stringifyFormulaRecursive(arg, baseSheetId, ss)));
      String arguments = newArgs.fold('', (prev, arg) => '$prev, $arg');
      return '${functionName.toUpperCase()}($arguments)';
      break;
    case "cell-ref":
      engine.CellCoordinates cellRef = expressionValue;
      SheetViewModel currentSheet = sheets.singleWhere((s) => s.id == baseSheetId);
      SheetViewModel refSheet = sheets.singleWhere((s) => s.id == cellRef.sheetId);

      String columnName = refSheet.activeColumnNames[cellRef.col];

      if (currentSheet == refSheet) {
        return '$columnName${cellRef.row + 1}';
      } else {
        return '${refSheet.name}!$columnName${cellRef.row + 1}';
      }
  }
  throw "Unknown type of formula, got $expressionType";
}
