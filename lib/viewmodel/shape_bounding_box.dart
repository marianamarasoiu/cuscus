part of cuscus.viewmodel;

class RectShapeBoundingBoxViewModel {
  view.RectShapeBoundingBoxView rectShapeBoundingBoxView;

  RectShapeBoundingBoxViewModel() {
    rectShapeBoundingBoxView = new view.RectShapeBoundingBoxView(this);
  }

  set onUpdate(view.RectUpdateFunction updateFunction) => rectShapeBoundingBoxView.updateFunction = updateFunction;

  show(ShapeViewModel shape) => rectShapeBoundingBoxView.showAroundShape(shape.shapeView);

  hide() => rectShapeBoundingBoxView.hide();
}

class LineShapeBoundingBoxViewModel {
  view.LineShapeBoundingBoxView lineShapeBoundingBoxView;

  LineShapeBoundingBoxViewModel() {
    lineShapeBoundingBoxView = new view.LineShapeBoundingBoxView(this);
  }

  set onUpdate(view.LineUpdateFunction updateFunction) => lineShapeBoundingBoxView.updateFunction = updateFunction;

  show(ShapeViewModel shape) => lineShapeBoundingBoxView.showAroundShape(shape.shapeView);

  hide() => lineShapeBoundingBoxView.hide();
}
