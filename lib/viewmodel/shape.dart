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

  commit() {
    properties.forEach((Rect property, var value) => commitProperty(property, value));
  }

  commitProperty(Rect property, var value) {
    List<String> columns = layer.graphicsSheetViewModel.activeColumnNames;
    int column = columns.indexOf(rectPropertyToColumnName[property]);

    engine.CellCoordinates cell = new engine.CellCoordinates(index, column, layer.graphicsSheetViewModel.id);
    String jsonParseTree = parser.parseFormula(value.toString());
    Map formulaParseTree = JSON.decode(jsonParseTree);
    var elementsResolvedTree = resolveSymbols(formulaParseTree, activeSheet.id, spreadsheetEngine);
    addNodeToSpreadsheetEngine(elementsResolvedTree, cell, spreadsheetEngine);

    // Propagate the changes in the dependency graph.
    spreadsheetEngine.depGraph.update();

    setupListenersForCell(property, cell);
  }

  setupListenersForCell(Rect property, engine.CellCoordinates cell) {
    engine.SpreadsheetDepNode node = spreadsheetEngine.cells[cell];
    node.onChange.listen((_) {
      properties[property] = node.computedValue.value;
      shapeView.setAttribute(rectPropertyToSvgProperty[property], node.computedValue.value.toString());
    });
    node.whenDone.then((_) {
      engine.SpreadsheetDepNode node = spreadsheetEngine.cells[cell];
      properties[property] = node.computedValue.value;
      shapeView.setAttribute(rectPropertyToSvgProperty[property], node.computedValue.value.toString());

      setupListenersForCell(property, cell);
    });
  }

  int get x => properties[Rect.x];
  set x (int value) {
    properties[Rect.x] = value;
    commit();
  }
  int get y => properties[Rect.y];
  set y (int value) {
    properties[Rect.y] = value;
    commit();
  }
  int get width => properties[Rect.width];
  set width (int value) {
    properties[Rect.width] = value;
    commit();
  }
  int get height => properties[Rect.height];
  set height (int value) {
    properties[Rect.height] = value;
    commit();
  }
}
