part of cuscus.view;

DivElement drawingToolContainer = querySelector('#drawing-tool-container');

viewmodel.DrawingTool buttonIdToDrawingTool(String id) {
  switch(id) {
    case 'rect-tool-button':
      return viewmodel.DrawingTool.rectangleTool;
    case 'ellipse-tool-button':
      return viewmodel.DrawingTool.ellipseTool;
    case 'line-tool-button':
      return viewmodel.DrawingTool.lineTool;
    case 'curve-tool-button':
      return viewmodel.DrawingTool.curveTool;
    case 'text-tool-button':
      return viewmodel.DrawingTool.textTool;
    case 'selection-tool-button':
      return viewmodel.DrawingTool.selectionTool;
  }
  throw 'Drawing tool not recognised, got $id';
}

DivElement drawingToolToButtonElement(viewmodel.DrawingTool drawingTool) {
  switch(drawingTool) {
    case viewmodel.DrawingTool.rectangleTool:
      return drawingToolContainer.querySelector('#rect-tool-button');
    case viewmodel.DrawingTool.ellipseTool:
      return drawingToolContainer.querySelector('#ellipse-tool-button');
    case viewmodel.DrawingTool.lineTool:
      return drawingToolContainer.querySelector('#line-tool-button');
    case viewmodel.DrawingTool.curveTool:
      return drawingToolContainer.querySelector('#curve-tool-button');
    case viewmodel.DrawingTool.textTool:
      return drawingToolContainer.querySelector('#text-tool-button');
    case viewmodel.DrawingTool.selectionTool:
      return drawingToolContainer.querySelector('#selection-tool-button');
  }
  throw "Drawing type not recognized, got $drawingTool";
}

viewmodel.DrawingTool _selectedTool = viewmodel.DrawingTool.selectionTool;
viewmodel.DrawingTool get selectedTool => _selectedTool;
set selectedTool(viewmodel.DrawingTool tool) {
  _selectedTool = tool;
  selectDrawingTool(tool);
}

void selectDrawingTool(viewmodel.DrawingTool drawingTool) {
  drawingToolContainer.querySelectorAll('.drawing-tool.button').forEach((button) => button.classes.remove('selected'));
  drawingToolToButtonElement(drawingTool).classes.add('selected');
}

//////////

StreamSubscription _dragMoveSub;
StreamSubscription _dragEndSub;
svg.SvgElement _tentativeElement;

startDrawing(MouseEvent mouseDown) {
  int startMouseX = mouseDown.client.x;
  int startMouseY = mouseDown.client.y;
  int tentativeX = startMouseX;
  int tentativeY = startMouseY;
  int tentativeWidth = startMouseX - startMouseX;
  int tentativeHeight = startMouseY - startMouseY;

  switch (selectedTool) {
    case viewmodel.DrawingTool.rectangleTool:
      _tentativeElement = new svg.RectElement();
      _tentativeElement.classes.add('tentative-shape');
      _tentativeElement.attributes['x'] = '$tentativeX';
      _tentativeElement.attributes['y'] = '$tentativeY';
      _tentativeElement.attributes['width'] = '$tentativeWidth';
      _tentativeElement.attributes['height'] = '$tentativeHeight';
      break;
    case viewmodel.DrawingTool.ellipseTool:
      _tentativeElement = new svg.EllipseElement();
      _tentativeElement.classes.add('tentative-shape');
      _tentativeElement.attributes['cx'] = '${tentativeX + tentativeWidth/2}';
      _tentativeElement.attributes['cy'] = '${tentativeY + tentativeHeight/2}';
      _tentativeElement.attributes['rx'] = '${tentativeWidth/2}';
      _tentativeElement.attributes['ry'] = '${tentativeHeight/2}';
      break;
    case viewmodel.DrawingTool.lineTool:
      _tentativeElement = new svg.LineElement();
      _tentativeElement.classes.add('tentative-shape');
      _tentativeElement.attributes['x1'] = '$tentativeX';
      _tentativeElement.attributes['y1'] = '$tentativeY';
      _tentativeElement.attributes['x2'] = '${tentativeX + tentativeWidth}';
      _tentativeElement.attributes['y2'] = '${tentativeY + tentativeHeight}';
      break;
    case viewmodel.DrawingTool.curveTool:
      _tentativeElement = new svg.LineElement(); // TODO: implement [curveTool]
      _tentativeElement.classes.add('tentative-shape');
      break;
    case viewmodel.DrawingTool.textTool:
      _tentativeElement = new svg.RectElement();
      _tentativeElement.classes.add('tentative-shape');
      _tentativeElement.attributes['x'] = '$tentativeX';
      _tentativeElement.attributes['y'] = '$tentativeY';
      _tentativeElement.attributes['width'] = '$tentativeWidth';
      _tentativeElement.attributes['height'] = '$tentativeHeight';
      break;
    case viewmodel.DrawingTool.selectionTool:
      break;
  }

  visCanvas.append(_tentativeElement);

  _dragMoveSub = visCanvas.onMouseMove.listen((mouseMove) {
    utils.stopDefaultBehaviour(mouseMove);
    int tentativeWidth = mouseMove.client.x - startMouseX;
    int tentativeX = startMouseX;
    int tentativeHeight = mouseMove.client.y - startMouseY;
    int tentativeY = startMouseY;
    
    int tentativeAbsWidth = tentativeWidth;
    int tentativeAbsX = tentativeX;
    int tentativeAbsHeight = tentativeHeight;
    int tentativeAbsY = tentativeY;
    if (tentativeAbsWidth <= 0) {
      tentativeAbsX = tentativeAbsX + tentativeAbsWidth;
      tentativeAbsWidth = tentativeAbsWidth.abs();
    }
    if (tentativeAbsHeight <= 0) {
      tentativeAbsY = tentativeAbsY + tentativeAbsHeight;
      tentativeAbsHeight = tentativeAbsHeight.abs();
    }

    switch (selectedTool) {
      case viewmodel.DrawingTool.rectangleTool:
        _tentativeElement.attributes['x'] = '$tentativeAbsX';
        _tentativeElement.attributes['y'] = '$tentativeAbsY';
        _tentativeElement.attributes['width'] = '$tentativeAbsWidth';
        _tentativeElement.attributes['height'] = '$tentativeAbsHeight';
        break;
      case viewmodel.DrawingTool.ellipseTool:
        _tentativeElement.attributes['cx'] = '${tentativeAbsX + tentativeAbsWidth/2}';
        _tentativeElement.attributes['cy'] = '${tentativeAbsY + tentativeAbsHeight/2}';
        _tentativeElement.attributes['rx'] = '${tentativeAbsWidth/2}';
        _tentativeElement.attributes['ry'] = '${tentativeAbsHeight/2}';
        break;
      case viewmodel.DrawingTool.lineTool:
        _tentativeElement.attributes['x2'] = '${tentativeX + tentativeWidth}';
        _tentativeElement.attributes['y2'] = '${tentativeY + tentativeHeight}';
        break;
      case viewmodel.DrawingTool.curveTool:
        break;
      case viewmodel.DrawingTool.textTool:
        _tentativeElement.attributes['width'] = '$tentativeWidth';
        _tentativeElement.attributes['height'] = '$tentativeHeight';
        break;
      case viewmodel.DrawingTool.selectionTool:
        break;
    }
  });

  _dragEndSub = visCanvas.onMouseUp.listen((mouseUp) {
    utils.stopDefaultBehaviour(mouseUp);
    int tentativeWidth = mouseUp.client.x - startMouseX;
    int tentativeX = startMouseX;
    int tentativeHeight = mouseUp.client.y - startMouseY;
    int tentativeY = startMouseY;
    
    int tentativeAbsWidth = tentativeWidth;
    int tentativeAbsX = tentativeX;
    int tentativeAbsHeight = tentativeHeight;
    int tentativeAbsY = tentativeY;
    if (tentativeAbsWidth <= 0) {
      tentativeAbsX = tentativeAbsX + tentativeAbsWidth;
      tentativeAbsWidth = tentativeAbsWidth.abs();
    }
    if (tentativeAbsHeight <= 0) {
      tentativeAbsY = tentativeAbsY + tentativeAbsHeight;
      tentativeAbsHeight = tentativeAbsHeight.abs();
    }

    switch (selectedTool) {
      case viewmodel.DrawingTool.rectangleTool:
        viewmodel.appController.command(viewmodel.UIAction.endDrawing, {
          'x': tentativeAbsX,
          'y': tentativeAbsY,
          'width': tentativeAbsWidth,
          'height': tentativeAbsHeight
          });
        break;
      case viewmodel.DrawingTool.lineTool:
        viewmodel.appController.command(viewmodel.UIAction.endDrawing, {
          'x1': tentativeX,
          'y1': tentativeY,
          'x2': tentativeX + tentativeWidth,
          'y2': tentativeY + tentativeHeight
          });
        break;
      default:
        throw "unsupported drawing tool, got $selectedTool";
    }
    _tentativeElement.remove();
    _dragMoveSub.cancel();
    _dragEndSub.cancel();
  });
}

cancelDrawing() {
  _tentativeElement.remove();
  _dragMoveSub.cancel();
  _dragEndSub.cancel();
}
