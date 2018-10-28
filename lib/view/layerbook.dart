part of cuscus.view;

class LayerbookView {
  viewmodel.LayerbookViewModel layerbookViewModel;

  List<LayerView> layers = [];

  svg.GElement groupElement;

  LayerbookView(this.layerbookViewModel) {
    groupElement = new svg.GElement();
    groupElement.attributes['data-layerbook-id'] = '${layerbookViewModel.id}';
    visCanvas.insertBefore(groupElement, viewmodel.RectShapeBoundingBoxViewModel.boundingBoxView.group);
  }

  addLayer(LayerView layer) {
    layers.add(layer);
    groupElement.append(layer.layerElement);
  }
}
