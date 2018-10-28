part of cuscus.view;

typedef void RectUpdateFunction({num x, num y, num width, num height});
typedef void LineUpdateFunction({num x1, num y1, num x2, num y2});

class RectShapeBoundingBoxView {
  svg.RectElement topLeftHandle;
  svg.RectElement topHandle;
  svg.RectElement topRightHandle;
  svg.RectElement rightHandle;
  svg.RectElement bottomRightHandle;
  svg.RectElement bottomHandle;
  svg.RectElement bottomLeftHandle;
  svg.RectElement leftHandle;
  svg.RectElement boundingBoxBorder;
  svg.RectElement tentativeShape;
  svg.GElement handleGroup;
  svg.GElement group;

  int handleWidth = 7;
  int handleHeight = 7;

  RectUpdateFunction updateFunction;

  int x;
  int y;
  int width;
  int height;

  RectShapeBoundingBoxView() {
    topLeftHandle = _createNewHandle()..id = "top-left-handle";
    topHandle = _createNewHandle()..id = "top-handle";
    topRightHandle = _createNewHandle()..id = "top-right-handle";
    rightHandle = _createNewHandle()..id = "right-handle";
    bottomRightHandle = _createNewHandle()..id = "bottom-right-handle";
    bottomHandle = _createNewHandle()..id = "bottom-handle";
    bottomLeftHandle = _createNewHandle()..id = "bottom-left-handle";
    leftHandle = _createNewHandle()..id = "left-handle";
    boundingBoxBorder = new svg.RectElement()
      ..classes.add("bounding-box-border")
      ..classes.add("shape-outline");
    tentativeShape = new svg.RectElement()
      ..classes.add("tentative-shape");

    handleGroup = new svg.GElement()
      ..classes.add("handle-bounding-box")
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
      ..id = "rect-bounding-box"
      ..attributes["visibility"] = "hidden"
      ..append(boundingBoxBorder)
      ..append(handleGroup)
      ..append(tentativeShape);
    _hideTentativeShape();

    visCanvas.append(group);

    initListeners();
  }

  initListeners() {
    StreamSubscription dragMoveSub;
    StreamSubscription dragEndSub;
    StreamSubscription escKeySub;

    topLeftHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newX = x + movementX;
        int newWidth = width - movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        _setTentativeShapeAtCoords(newX, newY, newWidth, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newX = x + movementX;
        int newWidth = width - movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        // Commit the resize
        x = newX;
        y = newY;
        width = newWidth;
        height = newHeight;
        updateFunction(x: newX, y: newY, width: newWidth, height: newHeight);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
        escKeySub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });

    topHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseY = dragStart.client.y;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementY = dragMove.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        _setTentativeShapeAtCoords(x, newY, width, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        // Commit the resize
        y = newY;
        height = newHeight;
        updateFunction(y: newY, height: newHeight);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });

    topRightHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newX = x;
        int newWidth = width + movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        _setTentativeShapeAtCoords(newX, newY, newWidth, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newX = x;
        int newWidth = width + movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y + movementY;
        int newHeight = height - movementY;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        // Commit the resize
        x = newX;
        y = newY;
        width = newWidth;
        height = newHeight;
        updateFunction(x: newX, y: newY, width: newWidth, height: newHeight);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });

    rightHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movement = dragMove.client.x - startMouseX;
        int newX = x;
        int newWidth = width + movement;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        _setTentativeShapeAtCoords(newX, y, newWidth, height);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movement = dragEnd.client.x - startMouseX;
        int newX = x;
        int newWidth = width + movement;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        // Commit the resize
        x = newX;
        width = newWidth;
        updateFunction(x: newX, width: newWidth);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });

    bottomRightHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newX = x;
        int newWidth = width + movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY = y;
        int newHeight = height + movementY;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        _setTentativeShapeAtCoords(newX, newY, newWidth, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newX = x;
        int newWidth = width + movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y;
        int newHeight = height + movementY;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        // Commit the resize
        x = newX;
        y = newY;
        width = newWidth;
        height = newHeight;
        updateFunction(x: newX, y: newY, width: newWidth, height: newHeight);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });

    bottomHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseY = dragStart.client.y;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementY = dragMove.client.y - startMouseY;
        int newY = y;
        int newHeight = height + movementY;
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        _setTentativeShapeAtCoords(x, newY, width, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y;
        int newHeight = height + movementY;
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        // Commit the resize
        y = newY;
        height = newHeight;
        updateFunction(y: newY, height: newHeight);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });

    bottomLeftHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newX = x + movementX;
        int newWidth = width - movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY = y;
        int newHeight = height + movementY;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        _setTentativeShapeAtCoords(newX, newY, newWidth, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newX = x + movementX;
        int newWidth = width - movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y;
        int newHeight = height + movementY;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        // Commit the resize
        x = newX;
        y = newY;
        width = newWidth;
        height = newHeight;
        updateFunction(x: newX, y: newY, width: newWidth, height: newHeight);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });

    leftHandle.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movement = dragMove.client.x - startMouseX;
        int newX = x + movement;
        int newWidth = width - movement;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        _setTentativeShapeAtCoords(newX, y, newWidth, height);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movement = dragEnd.client.x - startMouseX;
        int newX = x + movement;
        int newWidth = width - movement;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        // Commit the resize
        x = newX;
        width = newWidth;
        updateFunction(x: newX, width: newWidth);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });

    boundingBoxBorder.onMouseDown.listen((MouseEvent dragStart) {
      // Listen only to left clicks.
      if (dragStart.button != 0) return;
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        print('mousemove');
        int movementX = dragMove.client.x - startMouseX;
        int newX = x + movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY = y + movementY;
        _setTentativeShapeAtCoords(newX, newY, width, height);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        print('mouseup');
        int movementX = dragEnd.client.x - startMouseX;
        int newX = x + movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY = y + movementY;
        // Commit the resize
        x = newX;
        y = newY;
        updateFunction(x: newX, y: newY);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
        escKeySub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        print('esc');
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
          escKeySub.cancel();
        }
      });
    });
  }

  showAroundShape(RectShapeView shape) {
    x = shape.x;
    y = shape.y;
    width = shape.width;
    height = shape.height;

    _showHandlesAndBox();
  }

  _showHandlesAndBox() {
    _setHandlesAtCoords(x, y, width, height);
    handleGroup.attributes["visibility"] = "visible";
    _setBoundingBoxsAtCoords(x, y, width, height);
    group.attributes["visibility"] = "visible";
  }

  _showTentativeShape() {
    tentativeShape.attributes["visibility"] = "visible";
  }
  _hideTentativeShape() {
    tentativeShape.attributes["visibility"] = "hidden";
  }
  _setTentativeShapeAtCoords(int x, int y, int width, int height) {
    tentativeShape
      ..attributes["x"] = "${x-1}"
      ..attributes["y"] = "${y-1}"
      ..attributes["width"] = "${width+2}"
      ..attributes["height"] = "${height+2}";
    group.attributes["visibility"] = "visible";
  }

  _setBoundingBoxsAtCoords(int x, int y, int width, int height) {
    boundingBoxBorder
      ..attributes["x"] = "${x-1}"
      ..attributes["y"] = "${y-1}"
      ..attributes["width"] = "${width+2}"
      ..attributes["height"] = "${height+2}";
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
      ..classes.add('bounding-box-handle')
      ..attributes["width"] = "$handleWidth"
      ..attributes["height"] = "$handleHeight";
  }
}

class LineShapeBoundingBoxView {
  svg.RectElement handle1;
  svg.RectElement handle2;
  svg.RectElement boundingBoxBorder;
  svg.LineElement shadowLine;
  svg.LineElement tentativeShape;
  svg.GElement handleGroup;
  svg.GElement group;

  int handleWidth = 7;
  int handleHeight = 7;

  LineUpdateFunction updateFunction;

  int x1;
  int y1;
  int x2;
  int y2;

  LineShapeBoundingBoxView() {
    handle1 = _createNewHandle()..id = "handle-1";
    handle2 = _createNewHandle()..id = "handle-2";
    boundingBoxBorder = new svg.RectElement()
      ..classes.add("bounding-box-border")
      ..attributes["fill-opacity"] = "0"
      ..attributes["stroke-width"] = "1"
      ..attributes["stroke"] = "dodgerblue";
    shadowLine = new svg.LineElement()
      ..id = "shadow-line"
      ..classes.add('shape-outline');
    tentativeShape = new svg.LineElement()
      ..classes.add("tentative-shape");

    handleGroup = new svg.GElement()
      ..classes.add("handle-bounding-box")
      ..attributes["visibility"] = "hidden"
      ..append(boundingBoxBorder)
      ..append(handle1)
      ..append(handle2);

    group = new svg.GElement()
      ..id = "line-bounding-box"
      ..attributes["visibility"] = "hidden"
      ..append(shadowLine)
      ..append(handleGroup)
      ..append(tentativeShape);
    _hideTentativeShape();

    visCanvas.append(group);

    initListeners();
  }

  initListeners() {
    StreamSubscription dragMoveSub;
    StreamSubscription dragEndSub;
    StreamSubscription escKeySub;

    handle1.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newX1 = x1 + movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY1 = y1 + movementY;
        _setTentativeShapeAtCoords(newX1, newY1, x2, y2);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newX1 = x1 + movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY1 = y1 + movementY;
        // Commit the resize
        x1 = newX1;
        y1 = newY1;

        updateFunction(x1: x1, y1: y1);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
        escKeySub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });

    handle2.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newX2 = x2 + movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY2 = y2 + movementY;
        _setTentativeShapeAtCoords(x1, y1, newX2, newY2);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newX2 = x2 + movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY2 = y2 + movementY;
        // Commit the resize
        x2 = newX2;
        y2 = newY2;

        updateFunction(x2: x2, y2: y2);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
        escKeySub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });

    boundingBoxBorder.onMouseDown.listen((MouseEvent dragStart) {
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      int startMouseX = dragStart.client.x;
      int startMouseY = dragStart.client.y;

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        int movementX = dragMove.client.x - startMouseX;
        int newX1 = x1 + movementX;
        int newX2 = x2 + movementX;
        int movementY = dragMove.client.y - startMouseY;
        int newY1 = y1 + movementY;
        int newY2 = y2 + movementY;
        _setTentativeShapeAtCoords(newX1, newY1, newX2, newY2);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        int movementX = dragEnd.client.x - startMouseX;
        int newX1 = x1 + movementX;
        int newX2 = x2 + movementX;
        int movementY = dragEnd.client.y - startMouseY;
        int newY1 = y1 + movementY;
        int newY2 = y2 + movementY;
        // Commit the resize
        x1 = newX1;
        y1 = newY1;
        x2 = newX2;
        y2 = newY2;
        updateFunction(x1: newX1, y1: newY1, x2: newX2, y2: newY2);
        _hideTentativeShape();
        _showHandlesAndBox();

        // Cancel the dragging
        dragMoveSub.cancel();
        dragEndSub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
        if (keyEvent.key == "Escape") {
          _hideTentativeShape();

          // Cancel the dragging
          dragMoveSub.cancel();
          dragEndSub.cancel();
        }
      });
    });
  }

  showAroundShape(LineShapeView shape) {
    x1 = shape.x1;
    y1 = shape.y1;
    x2 = shape.x2;
    y2 = shape.y2;

    _showHandlesAndBox();
  }

  _showHandlesAndBox() {
    _setHandlesAtCoords(x1, y1, x2, y2);
    _setBoundingBoxsAtCoords(x1, y1, x2, y2);
    handleGroup.attributes["visibility"] = "visible";
    _setLineAtCoords(x1, y1, x2, y2);
    group.attributes["visibility"] = "visible";
  }

  _showTentativeShape() {
    tentativeShape.attributes["visibility"] = "visible";
  }
  _hideTentativeShape() {
    tentativeShape.attributes["visibility"] = "hidden";
  }

  _setTentativeShapeAtCoords(int x1, int y1, int x2, int y2) {
    tentativeShape
      ..attributes["x1"] = "$x1"
      ..attributes["y1"] = "$y1"
      ..attributes["x2"] = "$x2"
      ..attributes["y2"] = "$y2";
  }
  
  _setBoundingBoxsAtCoords(int x1, int y1, int x2, int y2) {
    int x = math.min(x1, x2);
    int y = math.min(y1, y2);
    int width = (x2 - x1).abs();
    int height = (y2 - y1).abs();

    boundingBoxBorder
      ..attributes["x"] = "$x"
      ..attributes["y"] = "$y"
      ..attributes["width"] = "$width"
      ..attributes["height"] = "$height";
    group.attributes["visibility"] = "visible";
  }

  _setHandlesAtCoords(int x1, int y1, int x2, int y2) {
    handle1
      ..attributes["x"] = "${x1 - handleWidth/2}"
      ..attributes["y"] = "${y1 - handleHeight/2}";

    handle2
      ..attributes["x"] = "${x2 - handleWidth/2}"
      ..attributes["y"] = "${y2 - handleHeight/2}";
  }

  _setLineAtCoords(int x1, int y1, int x2, int y2) {
    shadowLine
      ..attributes["x1"] = "$x1"
      ..attributes["y1"] = "$y1"
      ..attributes["x2"] = "$x2"
      ..attributes["y2"] = "$y2";
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
