part of cuscus.view;

class BoundingBox {
  svg.RectElement topLeftHandle;
  svg.RectElement topHandle;
  svg.RectElement topRightHandle;
  svg.RectElement rightHandle;
  svg.RectElement bottomRightHandle;
  svg.RectElement bottomHandle;
  svg.RectElement bottomLeftHandle;
  svg.RectElement leftHandle;
  svg.RectElement boundingBoxBorder;
  svg.GElement group;

  int handleWidth = 5;
  int handleHeight = 5;

  BoundingBox() {
    topLeftHandle = _createNewHandle()..id = "top-left-handle";
    topHandle = _createNewHandle()..id = "top-handle";
    topRightHandle = _createNewHandle()..id = "top-right-handle";
    rightHandle = _createNewHandle()..id = "right-handle";
    bottomRightHandle = _createNewHandle()..id = "bottom-right-handle";
    bottomHandle = _createNewHandle()..id = "bottom-handle";
    bottomLeftHandle = _createNewHandle()..id = "bottom-left-handle";
    leftHandle = _createNewHandle()..id = "left-handle";
    boundingBoxBorder = new svg.RectElement()..id = "bounding-box-border"
      ..attributes["fill"] = ""
      ..attributes["stroke-width"] = "1"
      ..attributes["stroke"] = "dodgerblue";
    group = new svg.GElement()..id = "bounding-box"
      ..attributes["visibility"] = "hidden"
      ..append(topLeftHandle)
      ..append(topHandle)
      ..append(topRightHandle)
      ..append(rightHandle)
      ..append(bottomRightHandle)
      ..append(bottomHandle)
      ..append(bottomLeftHandle)
      ..append(leftHandle)
      ..append(boundingBoxBorder);
  }

  at(int x, int y, int width, int height) {
    boundingBoxBorder
      ..attributes["x"] = "$x"
      ..attributes["y"] = "$y"
      ..attributes["width"] = "$width"
      ..attributes["height"] = "$height";

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
      ..attributes["y"] = "${y + height/2 - handleHeight/2}";
    
    bottomLeftHandle
      ..attributes["x"] = "${x - handleWidth/2}"
      ..attributes["y"] = "${y + height - handleHeight/2}";

    leftHandle
      ..attributes["x"] = "${x - handleWidth/2}"
      ..attributes["y"] = "${y + height/2 - handleHeight/2}";
  }

  show() => group.attributes["visibility"] = "visible";

  hide() => group.attributes["visibility"] = "hidden";

  _createNewHandle() {
    return new svg.RectElement()
      ..attributes["width"] = "$handleWidth"
      ..attributes["height"] = "$handleHeight"
      ..attributes["fill"] = "#FFFFFF"
      ..attributes["stroke-width"] = "1"
      ..attributes["stroke"] = "dodgerblue";
  }
}