part of cuscus.view;

class LayerView {
  LayerViewModel layerViewModel;
  svg.GElement layerElement;

  List<ShapeView> shapes = [];

  LayerView(this.layerViewModel) {
    layerElement = new svg.GElement();
  }

  addShape(ShapeView shape) {
    shapes.add(shape);
    layerElement.append(shape.element);
  }

  remove() {
    layerElement.remove();
  }
}
