library playground;

import 'dart:html';

import 'package:cuscus/view/box_layout.dart' as box_layout;
import 'package:cuscus/viewmodel/viewmodel.dart' as viewmodel;

Playground get playground => _playground;

Playground _playground;

void init() => _playground = new Playground();

class Playground {
  DivElement get _mainBoxContainer => querySelector('#main-container'); // TODO: rename element to #main-box-container
  DivElement get _spreadsheetsContainer => querySelector('#sheets-container'); // TODO: rename element to #spreadsheets-container

  Playground() {
    // Init layout elements.
    new box_layout.Box(_mainBoxContainer);
    new box_layout.Box(_spreadsheetsContainer);

    // Create some spreadsheets
    {
      viewmodel.SheetbookViewModel sheetbook = new viewmodel.SheetbookViewModel();
      sheetbook.createView(_spreadsheetsContainer.querySelector('#left-sheet'));
      sheetbook.addSheet('DataSheet');
    }

    {
      viewmodel.SheetbookViewModel sheetbook = new viewmodel.SheetbookViewModel();
      sheetbook.createView(_spreadsheetsContainer.querySelector('#middle-sheet'));
      sheetbook.addSheet('DataSheet');
    }

    {
      viewmodel.SheetbookViewModel sheetbook = new viewmodel.SheetbookViewModel();
      sheetbook.createView(_spreadsheetsContainer.querySelector('#right-sheet'));
      sheetbook.addSheet('RectSheet');
    }

    viewmodel.initListeners();
  }
}