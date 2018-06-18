part of cuscus.view;

abstract class ShapeView {
  ShapeViewModel shapeViewModel;
  svg.SvgElement element;

  String getAttribute(String name) => element.getAttribute(name);
  setAttribute(String name, String value) => element.setAttribute(name, value);
}

abstract class RectShapeView extends ShapeView {
  int get x;
  int get y;
  int get width;
  int get height;
}

abstract class LineShapeView extends ShapeView {
  int get x1;
  int get y1;
  int get x2;
  int get y2;
}

class RectView extends RectShapeView {
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

class LineView extends LineShapeView {
  LineViewModel shapeViewModel;

  LineView(this.shapeViewModel) {
    element = new svg.LineElement();
    element.id = '${shapeViewModel.layer.graphicsSheetViewModel.id}-${shapeViewModel.index}';

    shapeViewModel.properties.forEach(
      (Line property, var value) => element.attributes[linePropertyToSvgProperty[property]] = value.toString());
  }

  int get x1 => shapeViewModel.properties[Line.x1];
  int get y1 => shapeViewModel.properties[Line.y1];
  int get x2 => shapeViewModel.properties[Line.x2];
  int get y2 => shapeViewModel.properties[Line.y2];
}
