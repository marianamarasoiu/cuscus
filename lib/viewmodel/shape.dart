part of cuscus.viewmodel;

abstract class ShapeViewModel {
  view.ShapeView shapeView;
  LayerViewModel layer;
  int index;

  Map properties;
}

abstract class RectShapeViewModel extends ShapeViewModel {
  int x;
  int y;
  int width;
  int height;
}

abstract class LineShapeViewModel extends ShapeViewModel {
  int x1;
  int y1;
  int x2;
  int y2;
}

class RectViewModel extends RectShapeViewModel {
  Map<Rect, dynamic> properties = {
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

  RectViewModel(LayerViewModel layer, int index, Map<Rect, dynamic> properties) {
    this.layer = layer;
    this.index = index;
    properties.forEach((Rect property, var value) => this.properties[property] = value);

    shapeView = new view.RectView(this);
  }

  RectViewModel.fromCellRow(LayerViewModel layer, int index) {
    this.layer = layer;
    this.index = index;

    properties.forEach((Rect property, var value) {
      List<String> columns = layer.graphicsSheetViewModel.activeColumnNames;
      int column = columns.indexOf(rectPropertyToColumnName[property]);
      engine.CellCoordinates cell = new engine.CellCoordinates(index, column, layer.graphicsSheetViewModel.id);
      engine.SpreadsheetDepNode node = spreadsheetEngineViewModel.cells[cell];
      properties[property] = node.computedValue.value;

      setupListenersForCell(property, cell);
    });

    shapeView = new view.RectView(this);
  }

  commit() {
    properties.forEach((Rect property, var value) => commitProperty(property, value));
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
    int column = columns.indexOf(rectPropertyToColumnName[property]);

    engine.CellCoordinates cell = new engine.CellCoordinates(index, column, layer.graphicsSheetViewModel.id);
    String jsonParseTree = parser.parseFormula(value.toString());
    Map formulaParseTree = JSON.decode(jsonParseTree);
    engine.CellContents cellContents = spreadsheetEngineViewModel.resolveSymbols(formulaParseTree, activeSheet.id);
    spreadsheetEngineViewModel.setNode(cellContents, cell);
    spreadsheetEngineViewModel.updateDependencyGraph();

    setupListenersForCell(property, cell);
  }

  setupListenersForCell(Rect property, engine.CellCoordinates cell) {
    engine.SpreadsheetDepNode node = spreadsheetEngineViewModel.cells[cell];

    // This is when the node has been changed due to value propagation in the engine.
    node.onChange.listen((_) {
      print('onchange');
      properties[property] = node.computedValue.value;

      shapeView.element.classes.add('animate');
      new Timer(new Duration(seconds: 1), () => shapeView.element.classes.remove('animate'));

      shapeView.setAttribute(rectPropertyToSvgProperty[property], node.computedValue.toString());
    });

    // This is when the node has been edited directly, which results in a replacement in the engine.
    node.whenDone.then((_) {
      print('when done');
      engine.SpreadsheetDepNode node = spreadsheetEngineViewModel.cells[cell];
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

  int get x => properties[Rect.x];
  set x (int value) {
    properties[Rect.x] = value;
    updatedFromDirectEdit[Rect.x] = true;
    commitProperty(Rect.x, value);
  }
  int get y => properties[Rect.y];
  set y (int value) {
    properties[Rect.y] = value;
    updatedFromDirectEdit[Rect.y] = true;
    commitProperty(Rect.y, value);
  }
  int get width => properties[Rect.width];
  set width (int value) {
    properties[Rect.width] = value;
    updatedFromDirectEdit[Rect.width] = true;
    commitProperty(Rect.width, value);
  }
  int get height => properties[Rect.height];
  set height (int value) {
    properties[Rect.height] = value;
    updatedFromDirectEdit[Rect.height] = true;
    commitProperty(Rect.height, value);
  }
}

class LineViewModel extends LineShapeViewModel {
  Map<Line, dynamic> properties = {
    Line.x1: 100,
    Line.y1: 100,
    Line.x2: 150,
    Line.y2: 150,
    Line.strokeColor: '#444',
    Line.strokeWidth: 1,
    Line.strokeOpacity: 1.0,
  };

  LineViewModel(LayerViewModel layer, int index, Map<Line, dynamic> properties) {
    this.layer = layer;
    this.index = index;
    properties.forEach((Line property, var value) => this.properties[property] = value);

    shapeView = new view.LineView(this);
  }

  LineViewModel.fromCellRow(LayerViewModel layer, int index) {
    this.layer = layer;
    this.index = index;

    properties.forEach((Line property, var value) {
      List<String> columns = layer.graphicsSheetViewModel.activeColumnNames;
      int column = columns.indexOf(linePropertyToColumnName[property]);
      engine.CellCoordinates cell = new engine.CellCoordinates(index, column, layer.graphicsSheetViewModel.id);
      engine.SpreadsheetDepNode node = spreadsheetEngineViewModel.cells[cell];
      properties[property] = node.computedValue.value;

      setupListenersForCell(property, cell);
    });

    shapeView = new view.LineView(this);
  }

  commit() {
    properties.forEach((Line property, var value) => commitProperty(property, value));
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
    int column = columns.indexOf(linePropertyToColumnName[property]);

    engine.CellCoordinates cell = new engine.CellCoordinates(index, column, layer.graphicsSheetViewModel.id);
    String jsonParseTree = parser.parseFormula(value.toString());
    Map formulaParseTree = JSON.decode(jsonParseTree);
    engine.CellContents cellContents = spreadsheetEngineViewModel.resolveSymbols(formulaParseTree, activeSheet.id);
    spreadsheetEngineViewModel.setNode(cellContents, cell);
    spreadsheetEngineViewModel.updateDependencyGraph();

    setupListenersForCell(property, cell);
  }

  setupListenersForCell(Line property, engine.CellCoordinates cell) {
    engine.SpreadsheetDepNode node = spreadsheetEngineViewModel.cells[cell];

    // This is when the node has been changed due to value propagation in the engine.
    node.onChange.listen((_) {
      properties[property] = node.computedValue.value;

      shapeView.element.classes.add('animate');
      new Timer(new Duration(seconds: 1), () => shapeView.element.classes.remove('animate'));

      shapeView.setAttribute(linePropertyToSvgProperty[property], node.computedValue.toString());
    });

    // This is when the node has been edited directly, which results in a replacement in the engine.
    node.whenDone.then((_) {
      engine.SpreadsheetDepNode node = spreadsheetEngineViewModel.cells[cell];
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

  int get x1 => properties[Line.x1];
  set x1 (int value) {
    properties[Line.x1] = value;
    updatedFromDirectEdit[Line.x1] = true;
    commitProperty(Line.x1, value);
  }
  int get y1 => properties[Line.y1];
  set y1 (int value) {
    properties[Line.y1] = value;
    updatedFromDirectEdit[Line.y1] = true;
    commitProperty(Line.y1, value);
  }
  int get x2 => properties[Line.x2];
  set x2 (int value) {
    properties[Line.x2] = value;
    updatedFromDirectEdit[Line.x2] = true;
    commitProperty(Line.x2, value);
  }
  int get y2 => properties[Line.y2];
  set y2 (int value) {
    properties[Line.y2] = value;
    updatedFromDirectEdit[Line.y2] = true;
    commitProperty(Line.y2, value);
  }
}
