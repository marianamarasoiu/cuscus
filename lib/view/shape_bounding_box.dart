part of cuscus.view;

typedef void UpdateFunction({num x, num y, num width, num height});

class ShapeBoundingBoxView {
  svg.RectElement topLeftHandle;
  svg.RectElement topHandle;
  svg.RectElement topRightHandle;
  svg.RectElement rightHandle;
  svg.RectElement bottomRightHandle;
  svg.RectElement bottomHandle;
  svg.RectElement bottomLeftHandle;
  svg.RectElement leftHandle;
  svg.RectElement boundingBoxBorder;
  svg.GElement handleGroup;
  svg.GElement group;

  int handleWidth = 5;
  int handleHeight = 5;

  UpdateFunction updateFunction;

  ShapeBoundingBoxViewModel shapeBoundingBoxViewModel;

  int x;
  int y;
  int width;
  int height;

  ShapeBoundingBoxView(this.shapeBoundingBoxViewModel) {
    topLeftHandle = _createNewHandle()..id = "top-left-handle";
    topHandle = _createNewHandle()..id = "top-handle";
    topRightHandle = _createNewHandle()..id = "top-right-handle";
    rightHandle = _createNewHandle()..id = "right-handle";
    bottomRightHandle = _createNewHandle()..id = "bottom-right-handle";
    bottomHandle = _createNewHandle()..id = "bottom-handle";
    bottomLeftHandle = _createNewHandle()..id = "bottom-left-handle";
    leftHandle = _createNewHandle()..id = "left-handle";
    boundingBoxBorder = new svg.RectElement()
      ..id = "bounding-box-border"
      ..attributes["fill-opacity"] = "0"
      ..attributes["stroke-width"] = "1"
      ..attributes["stroke"] = "dodgerblue";

    handleGroup = new svg.GElement()
      ..id = "handle-bounding-box"
      ..attributes["visibility"] = "hidden"
      ..append(topLeftHandle)
      ..append(topHandle)
      ..append(topRightHandle)
      ..append(rightHandle)
      ..append(bottomRightHandle)
      ..append(bottomHandle)
      ..append(bottomLeftHandle)
      ..append(leftHandle);

    group = new svg.GElement()
      ..id = "bounding-box"
      ..attributes["visibility"] = "hidden"
      ..append(boundingBoxBorder)
      ..append(handleGroup);

    initListeners();
  }

  initListeners() {
    StreamSubscription dragMoveSub;
    StreamSubscription dragEndSub;

    topLeftHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      handleGroup.attributes["visibility"] = "hidden";
      group.attributes["visibility"] = "visible";

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newX = x + movementX;
        int newWidth = width - movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        _setBoundingBoxAtCoords(newX, newY, newWidth, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newX = x + movementX;
        int newWidth = width - movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        // Commit the resize
        x = newX;
        y = newY;
        width = newWidth;
        height = newHeight;
        updateFunction(x: newX, y: newY, width: newWidth, height: newHeight);
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });
    });

    topHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseY = dragStart.client.y;

      handleGroup.attributes["visibility"] = "hidden";
      group.attributes["visibility"] = "visible";

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementY = dragMove.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        _setBoundingBoxAtCoords(x, newY, width, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        // Commit the resize
        y = newY;
        height = newHeight;
        updateFunction(y: newY, height: newHeight);
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });
    });

    topRightHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      handleGroup.attributes["visibility"] = "hidden";
      group.attributes["visibility"] = "visible";

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newWidth = width + movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        _setBoundingBoxAtCoords(x, newY, newWidth, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newWidth = width + movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        // Commit the resize
        y = newY;
        width = newWidth;
        height = newHeight;
        updateFunction(y: newY, width: newWidth, height: newHeight);
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });
    });

    rightHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;

      handleGroup.attributes["visibility"] = "hidden";
      group.attributes["visibility"] = "visible";

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movement = dragMove.client.x - startMouseX;
        int newWidth = width + movement;
        _setBoundingBoxAtCoords(x, y, newWidth, height);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movement = dragEnd.client.x - startMouseX;
        int newWidth = width + movement;
        // Commit the resize
        width = newWidth;
        updateFunction(width: newWidth);
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });
    });

    bottomRightHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      handleGroup.attributes["visibility"] = "hidden";
      group.attributes["visibility"] = "visible";

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newWidth = width + movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newHeight = height + movementY;
        _setBoundingBoxAtCoords(x, y, newWidth, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newWidth = width + movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newHeight = height + movementY;
        // Commit the resize
        width = newWidth;
        height = newHeight;
        updateFunction(width: newWidth, height: newHeight);
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });
    });

    bottomHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseY = dragStart.client.y;

      handleGroup.attributes["visibility"] = "hidden";
      group.attributes["visibility"] = "visible";

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementY = dragMove.client.y - startMouseY;
        int newHeight = height + movementY;
        _setBoundingBoxAtCoords(x, y, width, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementY = dragEnd.client.y - startMouseY;
        int newHeight = height + movementY;
        // Commit the resize
        height = newHeight;
        updateFunction(height: newHeight);
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });
    });

    bottomLeftHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      handleGroup.attributes["visibility"] = "hidden";
      group.attributes["visibility"] = "visible";

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newX = x + movementX;
        int newWidth = width - movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newHeight = height + movementY;
        _setBoundingBoxAtCoords(newX, y, newWidth, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newX = x + movementX;
        int newWidth = width - movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newHeight = height + movementY;
        // Commit the resize
        x = newX;
        width = newWidth;
        height = newHeight;
        updateFunction(x: newX, width: newWidth, height: newHeight);
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });
    });

    leftHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;

      handleGroup.attributes["visibility"] = "hidden";
      group.attributes["visibility"] = "visible";

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movement = dragMove.client.x - startMouseX;
        int newX = x + movement;
        int newWidth = width - movement;
        _setBoundingBoxAtCoords(newX, y, newWidth, height);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movement = dragEnd.client.x - startMouseX;
        int newX = x + movement;
        int newWidth = width - movement;
        // Commit the resize
        x = newX;
        width = newWidth;
        updateFunction(x: newX, width: newWidth);
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });
    });

    boundingBoxBorder.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      handleGroup.attributes["visibility"] = "hidden";
      group.attributes["visibility"] = "visible";

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newX = x + movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY = y + movementY;
        _setBoundingBoxAtCoords(newX, newY, width, height);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newX = x + movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y + movementY;
        // Commit the resize
        x = newX;
        y = newY;
        updateFunction(x: newX, y: newY);
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });
    });
  }

  showAroundShape(ShapeView shape) {
    x = shape.x;
    y = shape.y;
    width = shape.width;
    height = shape.height;

    _showHandlesAndBox();
  }

  _showHandlesAndBox() {
    _setHandlesAtCoords(x, y, width, height);
    handleGroup.attributes["visibility"] = "visible";
    _setBoundingBoxAtCoords(x, y, width, height);
    group.attributes["visibility"] = "visible";
  }

  _setBoundingBoxAtCoords(int x, int y, int width, int height) {
    boundingBoxBorder
      ..attributes["x"] = "$x"
      ..attributes["y"] = "$y"
      ..attributes["width"] = "$width"
      ..attributes["height"] = "$height";
    group.attributes["visibility"] = "visible";
  }

  _setHandlesAtCoords(int x, int y, int width, int height) {
    topLeftHandle
      ..attributes["x"] = "${x - handleWidth/2}"
      ..attributes["y"] = "${y - handleHeight/2}";

    topHandle
      ..attributes["x"] = "${x + width/2 - handleWidth/2}"
      ..attributes["y"] = "${y - handleHeight/2}";

    topRightHandle
      ..attributes["x"] = "${x + width - handleWidth/2}"
      ..attributes["y"] = "${y - handleHeight/2}";

    rightHandle
      ..attributes["x"] = "${x + width - handleWidth/2}"
      ..attributes["y"] = "${y + height/2 - handleHeight/2}";

    bottomRightHandle
      ..attributes["x"] = "${x + width - handleWidth/2}"
      ..attributes["y"] = "${y + height - handleHeight/2}";

    bottomHandle
      ..attributes["x"] = "${x + width/2 - handleWidth/2}"
      ..attributes["y"] = "${y + height - handleHeight/2}";

    bottomLeftHandle
      ..attributes["x"] = "${x - handleWidth/2}"
      ..attributes["y"] = "${y + height - handleHeight/2}";

    leftHandle
      ..attributes["x"] = "${x - handleWidth/2}"
      ..attributes["y"] = "${y + height/2 - handleHeight/2}";
  }

  hide() {
    group.attributes["visibility"] = "hidden";
    handleGroup.attributes["visibility"] = "hidden";
  }

  _createNewHandle() {
    return new svg.RectElement()
      ..attributes["width"] = "$handleWidth"
      ..attributes["height"] = "$handleHeight"
      ..attributes["fill"] = "#FFFFFF"
      ..attributes["stroke-width"] = "1"
      ..attributes["stroke"] = "dodgerblue";
  }
}
