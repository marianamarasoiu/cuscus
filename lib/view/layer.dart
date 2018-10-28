part of cuscus.view;

class LayerView {
  viewmodel.LayerViewModel layerViewModel;
  svg.GElement layerElement;

  List<ShapeView> shapes = [];

  LayerView(this.layerViewModel) {
    layerElement = new svg.GElement();
    layerElement.attributes['data-layer-id'] = '${layerViewModel.id}';
    layerElement.classes.add('layer');
    layerViewModel.layerbook.layerbookView.addLayer(this);
  }

  addShape(ShapeView shape) {
    shapes.add(shape);
    layerElement.append(shape.element);
  }

  remove() {
    layerElement.remove();
  }
}
