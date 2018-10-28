library utils;

import 'dart:html';

import 'package:cuscus/viewmodel/viewmodel.dart';

stopDefaultBehaviour(Event event) { // Move to a common utils file
  event.stopImmediatePropagation();
  event.stopPropagation();
  event.preventDefault();
}

final sheetbookTypes = SheetbookType.values.map((t) => t.toString()).toList();
final graphicMarkTypes = GraphicMarkType.values.map((t) => t.toString()).toList();

validateWorkspaceSerialisation(Map workspace) {

  verify(workspace.containsKey("sheetbooks"), true);
  verify(workspace["sheetbooks"].runtimeType, List);

  List sheetbooks = workspace["sheetbooks"];
  for (var sheetbook in sheetbooks) {
    verify(sheetbook.containsKey('sheetbook-id'), true);
    verify(sheetbook['sheetbook-id'].runtimeType, int);

    verify(sheetbook.containsKey('type'), true);
    verify(sheetbook['type'].runtimeType, String);
    verify(sheetbookTypes.contains(sheetbook['type']), true);

    verify(sheetbook.containsKey("sheets"), true);
    verify(sheetbook["sheets"].runtimeType, List);

    List sheets = sheetbook["sheets"];
    for (var sheet in sheets) {
      verify(sheet.containsKey('sheet-id'), true);
      verify(sheet['sheet-id'].runtimeType, int);

      verify(sheet.containsKey('name'), true);
      verify(sheet['name'].runtimeType, String);

      if (sheetbook['type'] == SheetbookType.graphics.toString()) {
        verify(sheet.containsKey('type'), true);
        verify(sheet['type'].runtimeType, String);
        verify(graphicMarkTypes.contains(sheet['type']), true);
      }

      verify(sheet.containsKey('row-count'), true);
      verify(sheet['row-count'].runtimeType, int);

      if (sheetbook['type'] == SheetbookType.data.toString()) {
        verify(sheet.containsKey('column-count'), true);
        verify(sheet['column-count'].runtimeType, int);
      }

      verify(sheet.containsKey("cells"), true);
      verify(sheet["cells"].runtimeType, List);

      List cells = sheet["cells"];
      for (var cell in cells) {
        verify(cell.containsKey('row'), true);
        verify(cell['row'].runtimeType, int);

        verify(cell.containsKey('column'), true);
        verify(cell['column'].runtimeType, int);

        verify(cell.containsKey('formula'), true);
        verify(cell['formula'].runtimeType, String);
      }
    }
  }
}

void verify(actual, expected) {
  if (actual != expected) {
    throw "Comparison failed! expected '$expected', got '$actual' instead.";
  }
}
