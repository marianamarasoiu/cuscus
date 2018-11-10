library cuscus.view;

import 'dart:async';
import 'dart:html';
import 'dart:math' as math;
import 'dart:svg' as svg;

import 'package:csv/csv.dart' as csv;

// Import the viewmodel
import 'package:cuscus/viewmodel/viewmodel.dart' as viewmodel;

// Import the utils
import 'package:cuscus/utils/utils.dart' as utils;

import 'box_layout.dart' as box_layout;


part 'cell.dart';
part 'sheet.dart';
part 'sheetbook.dart';

part 'shape.dart';
part 'layer.dart';
part 'layerbook.dart';

part 'cell_input.dart';
part 'shape_bounding_box.dart';
part 'graphic_toolbox.dart';

part 'shapes/group.dart';

part 'zoom_pan.dart';


DivElement get mainContainer => querySelector('#main-container');
DivElement get visContainer => querySelector('#vis-container');
svg.SvgSvgElement get visSvgContainer => querySelector("#vis-svg-container");
svg.GElement get visCanvas => querySelector("#vis-canvas");

DivElement get spreadsheetsContainer => querySelector('#spreadsheets-container');
DivElement get formulaBarContainer => querySelector('#formula-bar-container');
DivElement get sheetbooksContainer => querySelector('#sheetbooks-container');

InputElement get loadWorkspaceButton => querySelector('#load-workspace');
DivElement get saveWorkspaceButton => querySelector('#save-workspace-button');

box_layout.Box sheetbooksBox;

init() {
  // Init layout elements.
  new box_layout.Box(mainContainer);
  new box_layout.Box(spreadsheetsContainer);
  sheetbooksBox = new box_layout.Box(sheetbooksContainer);

  initZoomPan(visSvgContainer);
}
