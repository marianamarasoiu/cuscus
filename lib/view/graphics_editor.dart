part of cuscus.view;

class GraphicsEditorView {
  DivElement element;
  DivElement drawingToolContainer;

  GraphicsEditorViewModel graphicsEditorViewModel;

  Shape selectedShape;
  BoundingBox selectionBoundingBox;

  GraphicsEditorView(this.graphicsEditorViewModel) {
    drawingToolContainer = querySelector("#drawing-tool-container");
    drawingToolContainer.querySelectorAll(".shape-button").forEach((shapeButton) {
      shapeButton.onClick.listen((MouseEvent clickEvent) {
        command(InteractionAction.clickInToolPanel, buttonIdToShapeType(shapeButton.id));
      });
    });
  }

  selectShapeButton(ShapeType shapeType) {
    shapeTypeToButton(shapeType).classes.add('selected');
  }

  deselectShapeButton(ShapeType shapeType) {
    shapeTypeToButton(shapeType).classes.remove('selected');
  }

  deselectAllShapeButtons() {
    drawingToolContainer.querySelectorAll(".shape-button").forEach((shapeButton) {
      shapeButton.classes.remove('selected');
    });
  }

  ShapeType buttonIdToShapeType(String id) {
    switch(id) {
      case 'rect-button-shape':
        return ShapeType.rect;
      case 'ellipse-button-shape':
        return ShapeType.ellipse;
      case 'triangle-button-shape':
        return ShapeType.triangle;
      case 'line-button-shape':
        return ShapeType.line;
      case 'curve-button-shape':
        return ShapeType.curve;
      case 'text-button-shape':
        return ShapeType.text;
      default:
        throw 'Shape tool not recognised, got $id';
    }
  }

  DivElement shapeTypeToButton(ShapeType shapeType) {
    switch(shapeType) {
      case ShapeType.rect:
        return drawingToolContainer.querySelector('#rect-button-shape');
      case ShapeType.ellipse:
        return drawingToolContainer.querySelector('#ellipse-button-shape');
      case ShapeType.triangle:
        return drawingToolContainer.querySelector('#triangle-button-shape');
      case ShapeType.line:
        return drawingToolContainer.querySelector('#line-button-shape');
      case ShapeType.curve:
        return drawingToolContainer.querySelector('#curve-button-shape');
      case ShapeType.text:
        return drawingToolContainer.querySelector('#text-button-shape');
      default:
        throw "Shape type not recognized, got $shapeType";
    }
  }
}
