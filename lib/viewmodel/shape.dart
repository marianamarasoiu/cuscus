part of cuscus.viewmodel;

abstract class ShapeViewModel {
  static ShapeViewModel _selectedShape;
  static ShapeViewModel get selectedShape => _selectedShape;
  static void clear() => _selectedShape = null;

  view.ShapeView shapeView;
  LayerViewModel layer;
  num index;

  Map properties;

  void select() {
    if (_selectedShape == this) return;
    _selectedShape?.deselect();
    _selectedShape = this;
    _selectedShape.showBoundingBox();
    layer.graphicsSheetViewModel.selectRow(_selectedShape.index);
  }
  void deselect() {
    RectShapeBoundingBoxViewModel.hide();
    LineShapeBoundingBoxViewModel.hide();
    
    if (_selectedShape == null) return;
    layer.graphicsSheetViewModel.deselectRow(_selectedShape.index);
    _selectedShape = null;
  }

  void showBoundingBox();
}

abstract class RectShapeViewModel extends ShapeViewModel {
  num x;
  num y;
  num width;
  num height;
}

abstract class LineShapeViewModel extends ShapeViewModel {
  num x1;
  num y1;
  num x2;
  num y2;
}

class RectViewModel extends RectShapeViewModel {
  Map properties = <Rect, dynamic>{
    Rect.x: 100,
    Rect.y: 100,
    Rect.width: 50,
    Rect.height: 50,
    Rect.rx: 0,
    Rect.ry: 0,
    Rect.fillColor: '#fff',
    Rect.fillOpacity: 1.0,
    Rect.strokeColor: '#444',
    Rect.strokeWidth: 1,
    Rect.strokeOpacity: 1.0,
    Rect.opacity: 1.0
  };

  RectViewModel(LayerViewModel layer, num index, Map properties) {
    this.layer = layer;
    this.index = index;
    properties.forEach((property, value) => this.properties[property as Rect] = value);

    shapeView = new view.RectView(this);
  }

  RectViewModel.fromCellRow(LayerViewModel layer, num index) {
    this.layer = layer;
    this.index = index;

    properties.forEach((property, value) {
      List<String> columns = layer.graphicsSheetViewModel.activeColumnNames;
      num column = columns.indexOf(rectPropertyToColumnName[property]);
      engine.CellCoordinates cell = new engine.CellCoordinates(index, column, layer.graphicsSheetViewModel.id);
      engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];
      properties[property] = node.computedValue.value;

      setupListenersForCell(property, cell);
    });

    shapeView = new view.RectView(this);
  }

  commit() {
    properties.forEach((property, value) => commitProperty(property, value));
  }

  /// When the shape is changed directly, the node in the engine is replaced. For this case,
  /// we don't want to duplicate the number of listeners on the node by adding another listener on the node in the whenDone event.
  Map updatedFromDirectEdit = {
    Rect.x: false,
    Rect.y: false,
    Rect.width: false,
    Rect.height: false
  };

  commitProperty(Rect property, var value) {
    List<String> columns = layer.graphicsSheetViewModel.activeColumnNames;
    num column = columns.indexOf(rectPropertyToColumnName[property]);

    engine.CellCoordinates cell = new engine.CellCoordinates(index, column, layer.graphicsSheetViewModel.id);
    String jsonParseTree = parser.parseFormula(value.toString());
    Map formulaParseTree = jsonDecode(jsonParseTree);
    engine.CellContents cellContents = SpreadsheetEngineViewModel.spreadsheet.resolveSymbols(formulaParseTree, SheetViewModel.activeSheet.id);
    SpreadsheetEngineViewModel.spreadsheet.setNode(cellContents, cell);
    SpreadsheetEngineViewModel.spreadsheet.updateDependencyGraph();

    setupListenersForCell(property, cell);
  }

  setupListenersForCell(Rect property, engine.CellCoordinates cell) {
    engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];

    // This is when the node has been changed due to value propagation in the engine.
    node.onChange.listen((_) {
      properties[property] = node.computedValue.value;

      shapeView.element.classes.add('animate');
      new Timer(new Duration(seconds: 1), () => shapeView.element.classes.remove('animate'));

      shapeView.setAttribute(rectPropertyToSvgProperty[property], node.computedValue.toString());
    });

    // This is when the node has been edited directly, which results in a replacement in the engine.
    node.whenDone.then((_) {
      print('when done');
      engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];
      properties[property] = node.computedValue.value;

      if (updatedFromDirectEdit[property] == true) {
        updatedFromDirectEdit[property] = false;
      } else {
        shapeView.element.classes.add('animate');
        new Timer(new Duration(seconds: 1), () => shapeView.element.classes.remove('animate'));
        setupListenersForCell(property, cell);
      }

      shapeView.setAttribute(rectPropertyToSvgProperty[property], node.computedValue.toString());
    });
  }

  num get x => properties[Rect.x];
  set x (num value) {
    properties[Rect.x] = value;
    updatedFromDirectEdit[Rect.x] = true;
    commitProperty(Rect.x, value);
  }
  num get y => properties[Rect.y];
  set y (num value) {
    properties[Rect.y] = value;
    updatedFromDirectEdit[Rect.y] = true;
    commitProperty(Rect.y, value);
  }
  num get width => properties[Rect.width];
  set width (num value) {
    properties[Rect.width] = value;
    updatedFromDirectEdit[Rect.width] = true;
    commitProperty(Rect.width, value);
  }
  num get height => properties[Rect.height];
  set height (num value) {
    properties[Rect.height] = value;
    updatedFromDirectEdit[Rect.height] = true;
    commitProperty(Rect.height, value);
  }

  void showBoundingBox() {
    RectShapeBoundingBoxViewModel.show(this);
    RectShapeBoundingBoxViewModel.onUpdate = ({num x, num y, num width, num height}) {
      RectShapeViewModel rect = this;
      if (x != null) {
        rect.x = x;
      }
      if (y != null) {
        rect.y = y;
      }
      if (width != null) {
        rect.width = width;
      }
      if (height != null) {
        rect.height = height;
      }
    };
  }
}

class LineViewModel extends LineShapeViewModel {
  Map properties = <Line, dynamic>{
    Line.x1: 100,
    Line.y1: 100,
    Line.x2: 150,
    Line.y2: 150,
    Line.strokeColor: '#444',
    Line.strokeWidth: 1,
    Line.strokeOpacity: 1.0,
  };

  LineViewModel(LayerViewModel layer, num index, Map properties) {
    this.layer = layer;
    this.index = index;
    properties.forEach((property, value) => this.properties[property as Line] = value);

    shapeView = new view.LineView(this);
  }

  LineViewModel.fromCellRow(LayerViewModel layer, num index) {
    this.layer = layer;
    this.index = index;

    properties.forEach((property, var value) {
      List<String> columns = layer.graphicsSheetViewModel.activeColumnNames;
      num column = columns.indexOf(linePropertyToColumnName[property]);
      engine.CellCoordinates cell = new engine.CellCoordinates(index, column, layer.graphicsSheetViewModel.id);
      engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];
      properties[property] = node.computedValue.value;

      setupListenersForCell(property, cell);
    });

    shapeView = new view.LineView(this);
  }

  commit() {
    properties.forEach((property, var value) => commitProperty(property, value));
  }

  /// When the shape is changed directly, the node in the engine is replaced. For this case,
  /// we don't want to duplicate the number of listeners on the node by adding another listener on the node in the whenDone event.
  Map updatedFromDirectEdit = {
    Line.x1: false,
    Line.y1: false,
    Line.x2: false,
    Line.y2: false,
  };

  commitProperty(Line property, var value) {
    List<String> columns = layer.graphicsSheetViewModel.activeColumnNames;
    num column = columns.indexOf(linePropertyToColumnName[property]);

    engine.CellCoordinates cell = new engine.CellCoordinates(index, column, layer.graphicsSheetViewModel.id);
    String jsonParseTree = parser.parseFormula(value.toString());
    Map formulaParseTree = jsonDecode(jsonParseTree);
    engine.CellContents cellContents = SpreadsheetEngineViewModel.spreadsheet.resolveSymbols(formulaParseTree, SheetViewModel.activeSheet.id);
    SpreadsheetEngineViewModel.spreadsheet.setNode(cellContents, cell);
    SpreadsheetEngineViewModel.spreadsheet.updateDependencyGraph();

    setupListenersForCell(property, cell);
  }

  setupListenersForCell(Line property, engine.CellCoordinates cell) {
    engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];

    // This is when the node has been changed due to value propagation in the engine.
    node.onChange.listen((_) {
      properties[property] = node.computedValue.value;

      shapeView.element.classes.add('animate');
      new Timer(new Duration(seconds: 1), () => shapeView.element.classes.remove('animate'));

      shapeView.setAttribute(linePropertyToSvgProperty[property], node.computedValue.toString());
    });

    // This is when the node has been edited directly, which results in a replacement in the engine.
    node.whenDone.then((_) {
      engine.SpreadsheetDepNode node = SpreadsheetEngineViewModel.spreadsheet.cells[cell];
      properties[property] = node.computedValue.value;

      if (updatedFromDirectEdit[property] == true) {
        updatedFromDirectEdit[property] = false;
      } else {
        shapeView.element.classes.add('animate');
        new Timer(new Duration(seconds: 1), () => shapeView.element.classes.remove('animate'));
        setupListenersForCell(property, cell);
      }

      shapeView.setAttribute(linePropertyToSvgProperty[property], node.computedValue.toString());
    });
  }

  num get x1 => properties[Line.x1];
  set x1 (num value) {
    properties[Line.x1] = value;
    updatedFromDirectEdit[Line.x1] = true;
    commitProperty(Line.x1, value);
  }
  num get y1 => properties[Line.y1];
  set y1 (num value) {
    properties[Line.y1] = value;
    updatedFromDirectEdit[Line.y1] = true;
    commitProperty(Line.y1, value);
  }
  num get x2 => properties[Line.x2];
  set x2 (num value) {
    properties[Line.x2] = value;
    updatedFromDirectEdit[Line.x2] = true;
    commitProperty(Line.x2, value);
  }
  num get y2 => properties[Line.y2];
  set y2 (num value) {
    properties[Line.y2] = value;
    updatedFromDirectEdit[Line.y2] = true;
    commitProperty(Line.y2, value);
  }

  void showBoundingBox() {
    LineShapeBoundingBoxViewModel.show(this);
    LineShapeBoundingBoxViewModel.onUpdate = ({num x1, num y1, num x2, num y2}) {
      LineShapeViewModel line = this;
      if (x1 != null) {
        line.x1 = x1;
      }
      if (y1 != null) {
        line.y1 = y1;
      }
      if (x2 != null) {
        line.x2 = x2;
      }
      if (y2 != null) {
        line.y2 = y2;
      }
    };
  }
}
