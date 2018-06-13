part of cuscus.view;

class LayerView {
  LayerViewModel layerViewModel;
  svg.GElement layerElement;



  LayerView(this.layerViewModel) {
    layerElement = new svg.GElement();
  }

  remove() {
    layerElement.remove();
  }
}
