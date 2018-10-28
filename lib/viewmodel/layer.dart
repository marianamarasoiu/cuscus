part of cuscus.viewmodel;

abstract class LayerViewModel extends ObjectWithId {
  static List<LayerViewModel> layers = [];
  static LayerViewModel layerWithId(int id) => layers.singleWhere((layer) => layer.id == id);
  static void clear() => layers.clear();

  LayerbookViewModel layerbook;
  GraphicsSheetViewModel graphicsSheetViewModel;
  view.LayerView layerView;

  Map<int, ShapeViewModel> shapes = {};
  ShapeViewModel selectedShape;

  LayerViewModel._(this.layerbook, [int id]) : super(id) {
    layerView = new view.LayerView(this);
  }
  factory LayerViewModel(LayerbookViewModel layerbook, GraphicMarkType type) {
    LayerViewModel layer;
    switch (type) {
      case GraphicMarkType.line:
        layer = new LineLayerViewModel._(layerbook);
        break;
      case GraphicMarkType.rect:
        layer = new RectLayerViewModel._(layerbook);
        break;
      // TODO: implement ellipse and text layers
      // case GraphicMarkType.ellipse:
      //   layer = new EllipseLayerViewModel._(layerbook);
      //   break;
      // case GraphicMarkType.text:
      //   layer = new TextLayerViewModel._(layerbook);
      //   break;
      default:
        throw "Unsupported type $type.";
    }
    layers.add(layer);
    return layer;
  }

  ShapeViewModel addShape(int index, Map properties);
  ShapeViewModel addShapeFromRow(int index);

  // State data for the active sheet
  static LayerViewModel _activeLayer;
  static LayerViewModel get activeLayer => _activeLayer;

  void focus() {
    if (activeLayer == this) return;
    _activeLayer?.blur();
    _activeLayer = this;
  }

  void blur() {
    _activeLayer = null;
  }

  void update() {
    for (int i = 0; i < graphicsSheetViewModel.cells.length; i++) {
      if (graphicsSheetViewModel.cells[i].first.cellContents != null) {
        addShapeFromRow(i);
      }
    }
  }
}

class RectLayerViewModel extends LayerViewModel {

  RectLayerViewModel._(LayerbookViewModel layerbook, [int id]) : super._(layerbook, id);

  ShapeViewModel addShape(int index, Map properties) {
    RectViewModel rectViewModel = new RectViewModel(this, index, properties);
    rectViewModel.commit();

    shapes[index] = rectViewModel;
    layerView.addShape(rectViewModel.shapeView);
    return rectViewModel;
  }

  ShapeViewModel addShapeFromRow(int index) {
    RectViewModel rectViewModel = new RectViewModel.fromCellRow(this, index);

    shapes[index] = rectViewModel;
    layerView.addShape(rectViewModel.shapeView);
    return rectViewModel;
  }
}

class LineLayerViewModel extends LayerViewModel {

  LineLayerViewModel._(LayerbookViewModel layerbook, [int id]) : super._(layerbook, id);

  void selectShapeAtIndex(int index) {
    deselectShape();

    selectedShape = shapes[index];
    if (selectedShape == null) {
      print("Trying to select shape at row $index that doesn't exist yet.");
      LineShapeBoundingBoxViewModel.hide();
      return;
    }

    LineShapeBoundingBoxViewModel.show(selectedShape);
    LineShapeBoundingBoxViewModel.onUpdate = ({num x1, num y1, num x2, num y2}) {
      LineShapeViewModel line = selectedShape;
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

    graphicsSheetViewModel.selectRow(index);
  }

  void deselectShape() {
    if (selectedShape != null) {
      LineShapeBoundingBoxViewModel.hide();
      graphicsSheetViewModel.deselectRow(selectedShape.index);
      selectedShape = null;
    }
  }

  ShapeViewModel addShape(int index, Map properties) {
    LineViewModel lineViewModel = new LineViewModel(this, index, properties);
    lineViewModel.commit();

    shapes[index] = lineViewModel;
    layerView.addShape(lineViewModel.shapeView);
    return lineViewModel;
  }

  ShapeViewModel addShapeFromRow(int index) {
    LineViewModel lineViewModel = new LineViewModel.fromCellRow(this, index);

    shapes[index] = lineViewModel;
    layerView.addShape(lineViewModel.shapeView);
    return lineViewModel;
  }
}
