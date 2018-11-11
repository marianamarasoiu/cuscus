part of cuscus.viewmodel;

RectShapeBoundingBoxViewModel selectionRectBoundingBox;
LineShapeBoundingBoxViewModel selectionLineBoundingBox;

void setupBoundingBox() {
  selectionRectBoundingBox = new RectShapeBoundingBoxViewModel._();
  selectionLineBoundingBox = new LineShapeBoundingBoxViewModel._();
}

class RectShapeBoundingBoxViewModel {
  static view.RectShapeBoundingBoxView boundingBoxView = new view.RectShapeBoundingBoxView();

  RectShapeBoundingBoxViewModel._();

  static set onUpdate(view.RectUpdateFunction updateFunction) => boundingBoxView.updateFunction = updateFunction;

  static show(ShapeViewModel shape, {bool showHandles = true}) => boundingBoxView.showAroundShape(shape.shapeView, showHandles);

  static hide() => boundingBoxView.hide();
}

class LineShapeBoundingBoxViewModel {
  static view.LineShapeBoundingBoxView boundingBoxView = new view.LineShapeBoundingBoxView();

  LineShapeBoundingBoxViewModel._();

  static set onUpdate(view.LineUpdateFunction updateFunction) => boundingBoxView.updateFunction = updateFunction;

  static show(ShapeViewModel shape) => boundingBoxView.showAroundShape(shape.shapeView);

  static hide() => boundingBoxView.hide();
}
