part of cuscus.viewmodel;

abstract class LayerViewModel {
  view.LayerView layerView;
  Map<int, ShapeViewModel> shapes;

  GraphicsSheetViewModel graphicsSheetViewModel;

  LayerViewModel();

  ShapeViewModel selectedShape;

  void selectShapeAtIndex(int index);

  void deselectShape();

  ShapeViewModel addShape(int index, Map properties);
  ShapeViewModel addShapeFromRow(int index);
}

abstract class RectLayerViewModel extends LayerViewModel {
  Map<int, RectShapeViewModel> shapes = {};
  RectShapeViewModel selectedShape;

  void selectShapeAtIndex(int index) {
    deselectShape();

    selectedShape = shapes[index];
    if (selectedShape == null) {
      print("Trying to select shape at row $index that doesn't exist yet.");
      graphicsEditorViewModel.rectShapeBoundingBoxViewModel.hide();
      graphicsEditorViewModel.lineShapeBoundingBoxViewModel.hide();
      return;
    }

    graphicsEditorViewModel.rectShapeBoundingBoxViewModel.show(selectedShape);
    graphicsEditorViewModel.rectShapeBoundingBoxViewModel.onUpdate = ({num x, num y, num width, num height}) {
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
    if (selectedShape != null) {
      graphicsEditorViewModel.rectShapeBoundingBoxViewModel.hide();
      graphicsSheetViewModel.deselectRow(selectedShape.index);
      selectedShape = null;
    }
  }
}

class RectLayer extends RectLayerViewModel {

  RectViewModel addShape(int index, Map<Rect, dynamic> properties) {
    RectViewModel rectViewModel = new RectViewModel(this, index, properties);
    rectViewModel.commit();

    shapes[index] = rectViewModel;
    layerView.addShape(rectViewModel.shapeView);
    return rectViewModel;
  }

  ShapeViewModel addShapeFromRow(int index) {
    RectViewModel rectViewModel = new RectViewModel.fromCellRow(this, index);

    shapes[index] = rectViewModel;
    layerView.addShape(rectViewModel.shapeView);
    return rectViewModel;
  }
}

abstract class LineLayerViewModel extends LayerViewModel {
  Map<int, LineShapeViewModel> shapes = {};
  LineShapeViewModel selectedShape;

  void selectShapeAtIndex(int index) {
    deselectShape();

    selectedShape = shapes[index];
    if (selectedShape == null) {
      print("Trying to select shape at row $index that doesn't exist yet.");
      graphicsEditorViewModel.lineShapeBoundingBoxViewModel.hide();
      return;
    }

    graphicsEditorViewModel.lineShapeBoundingBoxViewModel.show(selectedShape);
    graphicsEditorViewModel.lineShapeBoundingBoxViewModel.onUpdate = ({num x1, num y1, num x2, num y2}) {
      if (x1 != null) {
        selectedShape.x1 = x1;
      }
      if (y1 != null) {
        selectedShape.y1 = y1;
      }
      if (x2 != null) {
        selectedShape.x2 = x2;
      }
      if (y2 != null) {
        selectedShape.y2 = y2;
      }
    };

    graphicsSheetViewModel.selectRow(index);
  }

  void deselectShape() {
    if (selectedShape != null) {
      graphicsEditorViewModel.lineShapeBoundingBoxViewModel.hide();
      graphicsSheetViewModel.deselectRow(selectedShape.index);
      selectedShape = null;
    }
  }
}

class LineLayer extends LineLayerViewModel {

  LineViewModel addShape(int index, Map<Line, dynamic> properties) {
    LineViewModel lineViewModel = new LineViewModel(this, index, properties);
    lineViewModel.commit();

    shapes[index] = lineViewModel;
    layerView.addShape(lineViewModel.shapeView);
    return lineViewModel;
  }

  ShapeViewModel addShapeFromRow(int index) {
    LineViewModel lineViewModel = new LineViewModel.fromCellRow(this, index);

    shapes[index] = lineViewModel;
    layerView.addShape(lineViewModel.shapeView);
    return lineViewModel;
  }
}
