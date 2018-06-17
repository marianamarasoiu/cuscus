part of cuscus.viewmodel;

abstract class ShapeViewModel {
  view.ShapeView shapeView;
  LayerViewModel layer;
  int index;

  Map properties;
  int x;
  int y;
  int width;
  int height;
}

class RectViewModel extends ShapeViewModel {
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
      engine.SpreadsheetDepNode node = spreadsheetEngine.cells[cell];
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
  bool updatedFromDirectEdit = false;

  commitProperty(Rect property, var value) {
    List<String> columns = layer.graphicsSheetViewModel.activeColumnNames;
    int column = columns.indexOf(rectPropertyToColumnName[property]);

    engine.CellCoordinates cell = new engine.CellCoordinates(index, column, layer.graphicsSheetViewModel.id);
    String jsonParseTree = parser.parseFormula(value.toString());
    Map formulaParseTree = JSON.decode(jsonParseTree);
    engine.CellContents cellContents = resolveSymbols(formulaParseTree, activeSheet.id, spreadsheetEngine);
    addNodeToSpreadsheetEngine(cellContents, cell, spreadsheetEngine);

    // Propagate the changes in the dependency graph.
    spreadsheetEngine.depGraph.update();

    setupListenersForCell(property, cell);
  }

  setupListenersForCell(Rect property, engine.CellCoordinates cell) {
    engine.SpreadsheetDepNode node = spreadsheetEngine.cells[cell];

    // This is when the node has been changed due to value propagation in the engine.
    node.onChange.listen((_) {
      print('onchange');
      properties[property] = node.computedValue.value;

      shapeView.element.classes.add('animate');
      new Timer(new Duration(seconds: 1), () => shapeView.element.classes.remove('animate'));

      shapeView.setAttribute(rectPropertyToSvgProperty[property], node.computedValue.value.toString());
    });

    // This is when the node has been edited directly, which results in a replacement in the engine.
    node.whenDone.then((_) {
      print('when done');
        engine.SpreadsheetDepNode node = spreadsheetEngine.cells[cell];

        properties[property] = node.computedValue.value;

      if (!updatedFromDirectEdit) {
        shapeView.element.classes.add('animate');
        new Timer(new Duration(seconds: 1), () => shapeView.element.classes.remove('animate'));
        setupListenersForCell(property, cell);
      } else {
        updatedFromDirectEdit = false;
      }

        shapeView.setAttribute(rectPropertyToSvgProperty[property], node.computedValue.value.toString());

    });
  }

  int get x => properties[Rect.x];
  set x (int value) {
    properties[Rect.x] = value;
    updatedFromDirectEdit = true;
    commitProperty(Rect.x, value);
  }
  int get y => properties[Rect.y];
  set y (int value) {
    properties[Rect.y] = value;
    updatedFromDirectEdit = true;
    commitProperty(Rect.y, value);
  }
  int get width => properties[Rect.width];
  set width (int value) {
    properties[Rect.width] = value;
    updatedFromDirectEdit = true;
    commitProperty(Rect.width, value);
  }
  int get height => properties[Rect.height];
  set height (int value) {
    properties[Rect.height] = value;
    updatedFromDirectEdit = true;
    commitProperty(Rect.height, value);
  }
}
