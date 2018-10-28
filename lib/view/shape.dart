part of cuscus.view;

abstract class ShapeView {
  viewmodel.ShapeViewModel shapeViewModel;
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
  RectView(viewmodel.RectShapeViewModel shapeViewModel) {
    this.shapeViewModel = shapeViewModel;
    element = new svg.RectElement();
    element.attributes['data-index'] = '${shapeViewModel.index}';
    element.classes.add('shape');

    shapeViewModel.properties.forEach(
      (property, value) => element.attributes[viewmodel.rectPropertyToSvgProperty[property]] = value.toString());
  }

  int get x => shapeViewModel.properties[viewmodel.Rect.x];
  int get y => shapeViewModel.properties[viewmodel.Rect.y];
  int get width => shapeViewModel.properties[viewmodel.Rect.width];
  int get height => shapeViewModel.properties[viewmodel.Rect.height];
}

class LineView extends LineShapeView {
  LineView(viewmodel.LineShapeViewModel shapeViewModel) {
    this.shapeViewModel = shapeViewModel;
    element = new svg.LineElement();
    element.attributes['data-index'] = '${shapeViewModel.index}';
    element.classes.add('shape');

    shapeViewModel.properties.forEach((property, value) {
      element.attributes[viewmodel.linePropertyToSvgProperty[property]] = value.toString();
    });
  }

  int get x1 => shapeViewModel.properties[viewmodel.Line.x1];
  int get y1 => shapeViewModel.properties[viewmodel.Line.y1];
  int get x2 => shapeViewModel.properties[viewmodel.Line.x2];
  int get y2 => shapeViewModel.properties[viewmodel.Line.y2];
}
