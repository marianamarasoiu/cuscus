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
      case GraphicMarkType.text:
        layer = new TextLayerViewModel._(layerbook);
        break;
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

class TextLayerViewModel extends LayerViewModel {

  TextLayerViewModel._(LayerbookViewModel layerbook, [int id]) : super._(layerbook, id);

  ShapeViewModel addShape(int index, Map properties) {
    TextViewModel textViewModel = new TextViewModel(this, index, properties);
    textViewModel.commit();

    shapes[index] = textViewModel;
    layerView.addShape(textViewModel.shapeView);
    return textViewModel;
  }

  ShapeViewModel addShapeFromRow(int index) {
    TextViewModel textViewModel = new TextViewModel.fromCellRow(this, index);

    shapes[index] = textViewModel;
    layerView.addShape(textViewModel.shapeView);
    return textViewModel;
  }
}

class LineLayerViewModel extends LayerViewModel {

  LineLayerViewModel._(LayerbookViewModel layerbook, [int id]) : super._(layerbook, id);

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
