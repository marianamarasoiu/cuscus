part of cuscus.viewmodel;

class LayerbookViewModel extends ObjectWithId {
  view.LayerbookView layerbookView;
  SheetbookViewModel sheetbook;

  List<LayerViewModel> layers = [];
  LayerViewModel selectedLayer;

  static LayerbookViewModel _activeLayerbook;
  static LayerbookViewModel get activeLayerbook => _activeLayerbook;

  static void clear() {
    _activeLayerbook = null;
  }

  LayerbookViewModel(this.sheetbook) : super() {
    layerbookView = new view.LayerbookView(this);
  }

  addLayer(GraphicMarkType type) {
    LayerViewModel layer = new LayerViewModel(this, type);
    layers.add(layer);
    view.LayerView layerView = new view.LayerView(layer);
    layer.layerView = layerView;
    layerbookView.addLayer(layerView);
    layer.focus();
    return layer;
  }

  void focus() {
    if (activeLayerbook == this) return;
    _activeLayerbook?.blur();
    _activeLayerbook = this;
  }

  void blur() {
    _activeLayerbook = null;
  }
}
