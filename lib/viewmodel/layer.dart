part of cuscus.viewmodel;

abstract class LayerViewModel {
  view.LayerView layerView;
  Map<int, ShapeViewModel> shapes = {};

  GraphicsSheetViewModel graphicsSheetViewModel;

  LayerViewModel();

  ShapeViewModel selectedShape;

  void selectShapeAtIndex(int index) {
    selectedShape = shapes[index];
    if (selectedShape == null) {
      print("Trying to select shape at row $index that doesn't exist yet.");
      graphicsEditorViewModel.shapeBoundingBoxViewModel.hide();
      return;
    }

    graphicsEditorViewModel.shapeBoundingBoxViewModel.show(selectedShape);
    graphicsEditorViewModel.shapeBoundingBoxViewModel.onUpdate = ({num x, num y, num width, num height}) {
      if (x != null) {
        selectedShape.x = x;
      }
      if (y != null) {
        selectedShape.y = y;
      }
      if (width != null) {
        selectedShape.width = width;
      }
      if (height != null) {
        selectedShape.height = height;
      }
    };

    graphicsSheetViewModel.selectRow(index);
  }

  void deselectShape() {
    graphicsEditorViewModel.shapeBoundingBoxViewModel.hide();
    graphicsSheetViewModel.deselectRow(selectedShape.index);
    selectedShape = null;
  }

  ShapeViewModel addShape(int index, {int x, int y, int width, int height});
}

class RectLayer extends LayerViewModel {

  RectViewModel addShape(int index, {int x, int y, int width, int height}) {
    RectViewModel rectViewModel = new RectViewModel(this, index, {Rect.x: x, Rect.y: y, Rect.width: width, Rect.height: height});
    rectViewModel.commit();

    shapes[index] = rectViewModel;
    layerView.addShape(rectViewModel.shapeView);
    return rectViewModel;
  }
}
