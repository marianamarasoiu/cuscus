part of cuscus.view;

abstract class ShapeView {
  ShapeViewModel shapeViewModel;
  svg.SvgElement element;

  int get x;
  int get y;
  int get width;
  int get height;

  String getAttribute(String name) => element.getAttribute(name);
  setAttribute(String name, String value) => element.setAttribute(name, value);
}

class RectView extends ShapeView {
  RectViewModel shapeViewModel;

  RectView(this.shapeViewModel) {
    element = new svg.RectElement();
    element.id = '${shapeViewModel.layer.graphicsSheetViewModel.id}-${shapeViewModel.index}';

    shapeViewModel.properties.forEach(
      (Rect property, var value) => element.attributes[rectPropertyToSvgProperty[property]] = value.toString());
  }

  int get x => shapeViewModel.properties[Rect.x];
  int get y => shapeViewModel.properties[Rect.y];
  int get width => shapeViewModel.properties[Rect.width];
  int get height => shapeViewModel.properties[Rect.height];
}
