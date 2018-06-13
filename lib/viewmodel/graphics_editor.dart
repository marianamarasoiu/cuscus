part of cuscus.viewmodel;

class GraphicsEditorViewModel extends ObjectWithId {
  view.GraphicsEditorView graphicsEditorView;
  SheetbookViewModel sheetbook;

  GraphicsEditorViewModel(SheetbookViewModel sheetbook) : super() {
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
      default:
        throw 'Unrecognised shape type, got $type';
        break;
    }

    view.LayerView layerView = new view.LayerView(layer);
    layer.layerView = layerView;
    graphicsEditorView.addLayer(layerView);
    selectLayer(layer);
    return layer;
  }

  void selectLayer(LayerViewModel layer) {
    // selectedLayer = layer;
    // graphicsEditorView.selectedLayer = layer.layerView;
    // graphicsEditorView.showSelectedLayer();
  }
}
