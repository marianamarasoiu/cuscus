part of cuscus.view;

class GraphicsEditorView {
  svg.SvgSvgElement canvasElement;
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

    canvasElement = querySelector("#canvas");
    canvasElement.onMouseDown.listen((mouseDown) => command(InteractionAction.mouseDownOnCanvas, mouseDown));
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

  startDrawing(MouseEvent mouseDown) {
    int startPositionX = mouseDown.client.x;
    int startPositionY = mouseDown.client.y;
    int tentativeWidth = mouseDown.client.x - startPositionX;
    int tentativeHeight = mouseDown.client.y - startPositionY;

    svg.SvgElement tentativeElement;
    switch (shapeToDraw) {
      case ShapeType.rect:
        tentativeElement = new svg.RectElement();
        tentativeElement.classes.add('tentative-shape');
        tentativeElement.attributes['x'] = '$startPositionX';
        tentativeElement.attributes['y'] = '$startPositionY';
        tentativeElement.attributes['width'] = '$tentativeWidth';
        tentativeElement.attributes['height'] = '$tentativeHeight';
        break;
      case ShapeType.ellipse:
        tentativeElement = new svg.EllipseElement();
        tentativeElement.classes.add('tentative-shape');
        tentativeElement.attributes['cx'] = '${startPositionX + tentativeWidth/2}';
        tentativeElement.attributes['cy'] = '${startPositionY + tentativeHeight/2}';
        tentativeElement.attributes['rx'] = '${tentativeWidth/2}';
        tentativeElement.attributes['ry'] = '${tentativeHeight/2}';
        break;
      case ShapeType.triangle:
        tentativeElement = new svg.RectElement(); // TODO: turn this into a triangle
        tentativeElement.classes.add('tentative-shape');
        break;
      case ShapeType.line:
        tentativeElement = new svg.LineElement();
        tentativeElement.classes.add('tentative-shape');
        tentativeElement.attributes['x1'] = '$startPositionX';
        tentativeElement.attributes['y1'] = '$startPositionY';
        tentativeElement.attributes['x2'] = '${startPositionX + tentativeWidth}';
        tentativeElement.attributes['y2'] = '${startPositionY + tentativeHeight}';
        break;
      case ShapeType.curve:
        tentativeElement = new svg.LineElement(); // TODO: this should behave differently
        tentativeElement.classes.add('tentative-shape');
        break;
      case ShapeType.text:
        tentativeElement = new svg.RectElement();
        tentativeElement.classes.add('tentative-shape');
        tentativeElement.attributes['x'] = '$startPositionX';
        tentativeElement.attributes['y'] = '$startPositionY';
        tentativeElement.attributes['width'] = '$tentativeWidth';
        tentativeElement.attributes['height'] = '$tentativeHeight';
        break;
    }

    canvasElement.append(tentativeElement);


    StreamSubscription dragMoveSub;
    StreamSubscription dragEndSub;

    dragMoveSub = canvasElement.onMouseMove.listen((mouseMove) {
      stopDefaultBehaviour(mouseMove);
      int tentativeWidth = mouseMove.client.x - startPositionX;
      int tentativeHeight = mouseMove.client.y - startPositionY;

      switch (shapeToDraw) {
        case ShapeType.rect:
          tentativeElement.attributes['width'] = '$tentativeWidth';
          tentativeElement.attributes['height'] = '$tentativeHeight';
          break;
        case ShapeType.ellipse:
          tentativeElement.attributes['cx'] = '${startPositionX + tentativeWidth/2}';
          tentativeElement.attributes['cy'] = '${startPositionY + tentativeHeight/2}';
          tentativeElement.attributes['rx'] = '${tentativeWidth/2}';
          tentativeElement.attributes['ry'] = '${tentativeHeight/2}';
          break;
        case ShapeType.triangle:
          break;
        case ShapeType.line:
          tentativeElement.attributes['x2'] = '${startPositionX + tentativeWidth}';
          tentativeElement.attributes['y2'] = '${startPositionY + tentativeHeight}';
          break;
        case ShapeType.curve:
          break;
        case ShapeType.text:
          tentativeElement.attributes['width'] = '$tentativeWidth';
          tentativeElement.attributes['height'] = '$tentativeHeight';
          break;
      }
    });

    dragEndSub = canvasElement.onMouseUp.listen((mouseUp) {
      stopDefaultBehaviour(mouseUp);
      command(InteractionAction.mouseUpOnCanvas, {
        'x': startPositionX,
        'y': startPositionY,
        'width': tentativeWidth,
        'height': tentativeHeight
        });
      dragMoveSub.cancel();
      dragEndSub.cancel();
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
