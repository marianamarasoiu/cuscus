part of cuscus.view;

class GraphicsEditorView {
  svg.SvgSvgElement canvasElement;
  DivElement drawingToolContainer;

  List<ShapeView> shapeViews = [];

  GraphicsEditorViewModel graphicsEditorViewModel;

  DrawingTool selectedTool = DrawingTool.selectionTool;
  ShapeBoundingBoxView selectionBoundingBox;

  GraphicsEditorView(this.graphicsEditorViewModel) {
    drawingToolContainer = querySelector("#drawing-tool-container");
    drawingToolContainer.querySelectorAll(".drawing-tool-button").forEach((toolButton) {
      toolButton.onClick.listen((MouseEvent clickEvent) {
        command(InteractionAction.clickInToolPanel, buttonIdToDrawingTool(toolButton.id));
      });
    });

    canvasElement = querySelector("#canvas");
    canvasElement.onMouseDown.listen((mouseDown) => command(InteractionAction.mouseDownOnCanvas, mouseDown));
  }

  addLayer(LayerView layer) {
    // TODO
  }

  selectDrawingTool(DrawingTool drawingTool) {
    drawingToolToButtonElement(selectedTool).classes.remove('selected');
    drawingToolToButtonElement(drawingTool).classes.add('selected');
    selectedTool = drawingTool;
  }

  startDrawing(MouseEvent mouseDown) {
    int startPositionX = mouseDown.client.x;
    int startPositionY = mouseDown.client.y;
    int tentativeWidth = mouseDown.client.x - startPositionX;
    int tentativeHeight = mouseDown.client.y - startPositionY;

    svg.SvgElement tentativeElement;
    switch (selectedDrawingTool) {
      case DrawingTool.rectangleTool:
        tentativeElement = new svg.RectElement();
        tentativeElement.classes.add('tentative-shape');
        tentativeElement.attributes['x'] = '$startPositionX';
        tentativeElement.attributes['y'] = '$startPositionY';
        tentativeElement.attributes['width'] = '$tentativeWidth';
        tentativeElement.attributes['height'] = '$tentativeHeight';
        break;
      case DrawingTool.ellipseTool:
        tentativeElement = new svg.EllipseElement();
        tentativeElement.classes.add('tentative-shape');
        tentativeElement.attributes['cx'] = '${startPositionX + tentativeWidth/2}';
        tentativeElement.attributes['cy'] = '${startPositionY + tentativeHeight/2}';
        tentativeElement.attributes['rx'] = '${tentativeWidth/2}';
        tentativeElement.attributes['ry'] = '${tentativeHeight/2}';
        break;
      case DrawingTool.lineTool:
        tentativeElement = new svg.LineElement();
        tentativeElement.classes.add('tentative-shape');
        tentativeElement.attributes['x1'] = '$startPositionX';
        tentativeElement.attributes['y1'] = '$startPositionY';
        tentativeElement.attributes['x2'] = '${startPositionX + tentativeWidth}';
        tentativeElement.attributes['y2'] = '${startPositionY + tentativeHeight}';
        break;
      case DrawingTool.curveTool:
        tentativeElement = new svg.LineElement(); // TODO: implement [curveTool]
        tentativeElement.classes.add('tentative-shape');
        break;
      case DrawingTool.textTool:
        tentativeElement = new svg.RectElement();
        tentativeElement.classes.add('tentative-shape');
        tentativeElement.attributes['x'] = '$startPositionX';
        tentativeElement.attributes['y'] = '$startPositionY';
        tentativeElement.attributes['width'] = '$tentativeWidth';
        tentativeElement.attributes['height'] = '$tentativeHeight';
        break;
      case DrawingTool.selectionTool:
        break;
    }

    canvasElement.append(tentativeElement);


    StreamSubscription dragMoveSub;
    StreamSubscription dragEndSub;

    dragMoveSub = canvasElement.onMouseMove.listen((mouseMove) {
      stopDefaultBehaviour(mouseMove);
      tentativeWidth = mouseMove.client.x - startPositionX;
      tentativeHeight = mouseMove.client.y - startPositionY;

      switch (selectedDrawingTool) {
        case DrawingTool.rectangleTool:
          tentativeElement.attributes['width'] = '$tentativeWidth';
          tentativeElement.attributes['height'] = '$tentativeHeight';
          break;
        case DrawingTool.ellipseTool:
          tentativeElement.attributes['cx'] = '${startPositionX + tentativeWidth/2}';
          tentativeElement.attributes['cy'] = '${startPositionY + tentativeHeight/2}';
          tentativeElement.attributes['rx'] = '${tentativeWidth/2}';
          tentativeElement.attributes['ry'] = '${tentativeHeight/2}';
          break;
        case DrawingTool.lineTool:
          tentativeElement.attributes['x2'] = '${startPositionX + tentativeWidth}';
          tentativeElement.attributes['y2'] = '${startPositionY + tentativeHeight}';
          break;
        case DrawingTool.curveTool:
          break;
        case DrawingTool.textTool:
          tentativeElement.attributes['width'] = '$tentativeWidth';
          tentativeElement.attributes['height'] = '$tentativeHeight';
          break;
        case DrawingTool.selectionTool:
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
      tentativeElement.remove();
      dragMoveSub.cancel();
      dragEndSub.cancel();
    });
  }

  DrawingTool buttonIdToDrawingTool(String id) {
    switch(id) {
      case 'rect-tool-button':
        return DrawingTool.rectangleTool;
      case 'ellipse-tool-button':
        return DrawingTool.ellipseTool;
      case 'line-tool-button':
        return DrawingTool.lineTool;
      case 'curve-tool-button':
        return DrawingTool.curveTool;
      case 'text-tool-button':
        return DrawingTool.textTool;
      case 'selection-tool-button':
        return DrawingTool.selectionTool;
    }
    throw 'Drawing tool not recognised, got $id';
  }

  DivElement drawingToolToButtonElement(DrawingTool drawingTool) {
    switch(drawingTool) {
      case DrawingTool.rectangleTool:
        return drawingToolContainer.querySelector('#rect-tool-button');
      case DrawingTool.ellipseTool:
        return drawingToolContainer.querySelector('#ellipse-tool-button');
      case DrawingTool.lineTool:
        return drawingToolContainer.querySelector('#line-tool-button');
      case DrawingTool.curveTool:
        return drawingToolContainer.querySelector('#curve-tool-button');
      case DrawingTool.textTool:
        return drawingToolContainer.querySelector('#text-tool-button');
      case DrawingTool.selectionTool:
        return drawingToolContainer.querySelector('#selection-tool-button');
    }
    throw "Drawing type not recognized, got $drawingTool";
  }
}
