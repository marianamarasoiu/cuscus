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

  static const initialHandleSize = 8.0;
  num handleSize = initialHandleSize;

  RectUpdateFunction updateFunction;

  num x = 0;
  num y = 0;
  num width = 0;
  num height = 0;

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
      ..classes.add("shape-outline")
      ..attributes["vector-effect"] = "non-scaling-stroke";
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

    zoomCallbacks.add((double scroll) {
      var inverseFactor = _group.transform.baseVal.consolidate().matrix.inverse().a;
      handleSize = inverseFactor * initialHandleSize;
      _setHandlesAtCoords(x, y, width, height);
    });
  }

  initListeners() {
    StreamSubscription dragMoveSub;
    StreamSubscription dragEndSub;
    StreamSubscription escKeySub;

    topLeftHandle.onMouseDown.listen((MouseEvent dragStart) {
      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x + movementX;
        num newWidth = width - movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY = y + movementY;
        num newHeight = height - movementY;
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
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x + movementX;
        num newWidth = width - movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY = y + movementY;
        num newHeight = height - movementY;
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
      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementY = mousePoint.y - startPoint.y;
        num newY = y + movementY;
        num newHeight = height - movementY;
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        _setTentativeShapeAtCoords(x, newY, width, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementY = mousePoint.y - startPoint.y;
        num newY = y + movementY;
        num newHeight = height - movementY;
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
      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x;
        num newWidth = width + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY = y + movementY;
        num newHeight = height - movementY;
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
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x;
        num newWidth = width + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY = y + movementY;
        num newHeight = height - movementY;
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
      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x;
        num newWidth = width + movementX;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        _setTentativeShapeAtCoords(newX, y, newWidth, height);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x;
        num newWidth = width + movementX;
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
      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x;
        num newWidth = width + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY = y;
        num newHeight = height + movementY;
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
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x;
        num newWidth = width + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY = y;
        num newHeight = height + movementY;
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
      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementY = mousePoint.y - startPoint.y;
        num newY = y;
        num newHeight = height + movementY;
        if (newHeight <= 0) {
          newY = newY + newHeight;
          newHeight = newHeight.abs();
        }
        _setTentativeShapeAtCoords(x, newY, width, newHeight);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementY = mousePoint.y - startPoint.y;
        num newY = y;
        num newHeight = height + movementY;
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
      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x + movementX;
        num newWidth = width - movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY = y;
        num newHeight = height + movementY;
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
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x + movementX;
        num newWidth = width - movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY = y;
        num newHeight = height + movementY;
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
      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x + movementX;
        num newWidth = width - movementX;
        if (newWidth <= 0) {
          newX = newX + newWidth;
          newWidth = newWidth.abs();
        }
        _setTentativeShapeAtCoords(newX, y, newWidth, height);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movement = mousePoint.x - startPoint.x;
        num newX = x + movement;
        num newWidth = width - movement;
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

      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY = y + movementY;
        _setTentativeShapeAtCoords(newX, newY, width, height);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX = x + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY = y + movementY;
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

  bool showHandles;
  showAroundShape(RectShapeView shape, bool showHandles) {
    x = shape.x;
    y = shape.y;
    width = shape.width;
    height = shape.height;
    this.showHandles = showHandles;

    _showHandlesAndBox();
  }

  _showHandlesAndBox() {
    if (showHandles) {
      _setHandlesAtCoords(x, y, width, height);
      handleGroup.attributes["visibility"] = "visible";
    }
    _setBoundingBoxsAtCoords(x, y, width, height);
    _setTentativeShapeAtCoords(x, y, width, height);
    group.attributes["visibility"] = "visible";
  }

  _showTentativeShape() {
    tentativeShape.attributes["visibility"] = "visible";
  }
  _hideTentativeShape() {
    tentativeShape.attributes["visibility"] = "hidden";
  }
  _setTentativeShapeAtCoords(num x, num y, num width, num height) {
    tentativeShape
      ..attributes["x"] = "${x}"
      ..attributes["y"] = "${y}"
      ..attributes["width"] = "${width}"
      ..attributes["height"] = "${height}";
    group.attributes["visibility"] = "visible";
  }

  _setBoundingBoxsAtCoords(num x, num y, num width, num height) {
    boundingBoxBorder
      ..attributes["x"] = "${x}"
      ..attributes["y"] = "${y}"
      ..attributes["width"] = "${width}"
      ..attributes["height"] = "${height}";
    group.attributes["visibility"] = "visible";
  }

  _setHandlesAtCoords(num x, num y, num width, num height) {
    topLeftHandle
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize"
      ..attributes["x"] = "${x - handleSize/2}"
      ..attributes["y"] = "${y - handleSize/2}";

    topHandle
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize"
      ..attributes["x"] = "${x + width/2 - handleSize/2}"
      ..attributes["y"] = "${y - handleSize/2}";

    topRightHandle
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize"
      ..attributes["x"] = "${x + width - handleSize/2}"
      ..attributes["y"] = "${y - handleSize/2}";

    rightHandle
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize"
      ..attributes["x"] = "${x + width - handleSize/2}"
      ..attributes["y"] = "${y + height/2 - handleSize/2}";

    bottomRightHandle
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize"
      ..attributes["x"] = "${x + width - handleSize/2}"
      ..attributes["y"] = "${y + height - handleSize/2}";

    bottomHandle
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize"
      ..attributes["x"] = "${x + width/2 - handleSize/2}"
      ..attributes["y"] = "${y + height - handleSize/2}";

    bottomLeftHandle
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize"
      ..attributes["x"] = "${x - handleSize/2}"
      ..attributes["y"] = "${y + height - handleSize/2}";

    leftHandle
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize"
      ..attributes["x"] = "${x - handleSize/2}"
      ..attributes["y"] = "${y + height/2 - handleSize/2}";
  }

  hide() {
    group.attributes["visibility"] = "hidden";
    handleGroup.attributes["visibility"] = "hidden";
  }

  _createNewHandle() {
    return new svg.RectElement()
      ..classes.add('bounding-box-handle')
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize"
      ..attributes["vector-effect"] = "non-scaling-stroke";
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

  static const initialHandleSize = 8.0;
  num handleSize = initialHandleSize;

  LineUpdateFunction updateFunction;

  num x1 = 0;
  num y1 = 0;
  num x2 = 0;
  num y2 = 0;

  LineShapeBoundingBoxView() {
    handle1 = _createNewHandle()..id = "handle-1";
    handle2 = _createNewHandle()..id = "handle-2";
    boundingBoxBorder = new svg.RectElement()
      ..classes.add("bounding-box-border")
      ..classes.add("shape-outline")
      ..attributes["vector-effect"] = "non-scaling-stroke";
    shadowLine = new svg.LineElement()
      ..id = "shadow-line"
      ..classes.add('shape-outline')
      ..attributes["vector-effect"] = "non-scaling-stroke";
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

    zoomCallbacks.add((double scroll) {
      var inverseFactor = _group.transform.baseVal.consolidate().matrix.inverse().a;
      handleSize = inverseFactor * initialHandleSize;
      _setHandlesAtCoords(x1, y1, x2, y2);
    });
  }

  initListeners() {
    StreamSubscription dragMoveSub;
    StreamSubscription dragEndSub;
    StreamSubscription escKeySub;

    handle1.onMouseDown.listen((MouseEvent dragStart) {
      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX1 = x1 + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY1 = y1 + movementY;
        _setTentativeShapeAtCoords(newX1, newY1, x2, y2);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX1 = x1 + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY1 = y1 + movementY;
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
      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX2 = x2 + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY2 = y2 + movementY;
        _setTentativeShapeAtCoords(x1, y1, newX2, newY2);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX2 = x2 + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY2 = y2 + movementY;
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
      // Listen only to left clicks.
      if (dragStart.button != 0) return;

      utils.stopDefaultBehaviour(dragStart);
      if (updateFunction == null) {
        throw "Function associating dragging with changing the shape properties missing!";
      }
      svg.Point startPoint = getRelativePoint(getSvgPoint(dragStart.client.x, dragStart.client.y));

      _showTentativeShape();

      dragMoveSub = document.onMouseMove.listen((MouseEvent dragMove) {
        utils.stopDefaultBehaviour(dragMove);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragMove.client.x, dragMove.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX1 = x1 + movementX;
        num newX2 = x2 + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY1 = y1 + movementY;
        num newY2 = y2 + movementY;
        _setTentativeShapeAtCoords(newX1, newY1, newX2, newY2);
      });

      dragEndSub = document.onMouseUp.listen((MouseEvent dragEnd) {
        utils.stopDefaultBehaviour(dragEnd);
        svg.Point mousePoint = getRelativePoint(getSvgPoint(dragEnd.client.x, dragEnd.client.y));
        num movementX = mousePoint.x - startPoint.x;
        num newX1 = x1 + movementX;
        num newX2 = x2 + movementX;
        num movementY = mousePoint.y - startPoint.y;
        num newY1 = y1 + movementY;
        num newY2 = y2 + movementY;
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
        escKeySub.cancel();
      });

      escKeySub = document.onKeyDown.listen((KeyboardEvent keyEvent) {
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
    _setTentativeShapeAtCoords(x1, y1, x2, y2);
    group.attributes["visibility"] = "visible";
  }

  _showTentativeShape() {
    tentativeShape.attributes["visibility"] = "visible";
  }
  _hideTentativeShape() {
    tentativeShape.attributes["visibility"] = "hidden";
  }

  _setTentativeShapeAtCoords(num x1, num y1, num x2, num y2) {
    tentativeShape
      ..attributes["x1"] = "$x1"
      ..attributes["y1"] = "$y1"
      ..attributes["x2"] = "$x2"
      ..attributes["y2"] = "$y2";
    group.attributes["visibility"] = "visible";
  }
  
  _setBoundingBoxsAtCoords(num x1, num y1, num x2, num y2) {
    num x = math.min(x1, x2);
    num y = math.min(y1, y2);
    num width = (x2 - x1).abs();
    num height = (y2 - y1).abs();

    boundingBoxBorder
      ..attributes["x"] = "$x"
      ..attributes["y"] = "$y"
      ..attributes["width"] = "$width"
      ..attributes["height"] = "$height";
    group.attributes["visibility"] = "visible";
  }

  _setHandlesAtCoords(num x1, num y1, num x2, num y2) {
    handle1
      ..attributes["x"] = "${x1 - handleSize/2}"
      ..attributes["y"] = "${y1 - handleSize/2}"
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize";

    handle2
      ..attributes["x"] = "${x2 - handleSize/2}"
      ..attributes["y"] = "${y2 - handleSize/2}"
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize";
  }

  _setLineAtCoords(num x1, num y1, num x2, num y2) {
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
      ..attributes["width"] = "$handleSize"
      ..attributes["height"] = "$handleSize"
      ..attributes["fill"] = "#FFFFFF"
      ..attributes["stroke-width"] = "1"
      ..attributes["stroke"] = "dodgerblue";
  }
}
