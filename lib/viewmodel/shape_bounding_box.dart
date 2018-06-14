part of cuscus.viewmodel;

class ShapeBoundingBoxViewModel {
  view.ShapeBoundingBoxView shapeBoundingBoxView;

  ShapeBoundingBoxViewModel() {
    shapeBoundingBoxView = new view.ShapeBoundingBoxView(this);
  }

  set onUpdate(view.UpdateFunction updateFunction) => shapeBoundingBoxView.updateFunction = updateFunction;

  show(ShapeViewModel shape) => shapeBoundingBoxView.showAroundShape(shape.shapeView);

  hide() => shapeBoundingBoxView.hide();
}
