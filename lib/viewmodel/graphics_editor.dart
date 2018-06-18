part of cuscus.viewmodel;

class GraphicsEditorViewModel extends ObjectWithId {
  view.GraphicsEditorView graphicsEditorView;
  SheetbookViewModel sheetbook;

  List<LayerViewModel> layers = [];
  LayerViewModel selectedLayer;

  RectShapeBoundingBoxViewModel rectShapeBoundingBoxViewModel;
  LineShapeBoundingBoxViewModel lineShapeBoundingBoxViewModel;

  GraphicsEditorViewModel(SheetbookViewModel sheetbook) : super() {
    this.rectShapeBoundingBoxViewModel = new RectShapeBoundingBoxViewModel();
    this.lineShapeBoundingBoxViewModel = new LineShapeBoundingBoxViewModel();
    this.sheetbook = sheetbook;
  }

  createView() {
    graphicsEditorView = new view.GraphicsEditorView(this);
  }

  addLayer(String type) {
    LayerViewModel layer;
    switch (type) {
      case 'RectLayer':
        layer = new RectLayer();
        break;
      case 'LineLayer':
        layer = new LineLayer();
        break;
      default:
        throw 'Unrecognised shape type, got $type';
        break;
    }

    layers.add(layer);

    view.LayerView layerView = new view.LayerView(layer);
    layer.layerView = layerView;
    graphicsEditorView.addLayer(layerView);
    selectLayer(layer);
    return layer;
  }

  void selectLayer(LayerViewModel layer) {
    selectedLayer?.deselectShape();
    selectedLayer = layer;
  }
}
