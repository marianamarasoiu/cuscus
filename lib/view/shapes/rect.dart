part of cuscus.view;

class Shape {
  svg.SvgElement element;
  bool opRelativeToCentre;
  int x, y;
  int width, height;
}

Map<String, String> defaultStyle = {
  "color": "#000",
  "fill": "#fff",
  "fill-opacity": "1",
  "opacity": "1",
  "stroke": "#444",
  "stroke-opacity": "1",
  "stroke-width": "1"
};

class Rect extends Shape {
  int _x, _y;
  int _width, _height;

  Rect(this._x, this._y, this._width, this._height) {
    element = new svg.RectElement();
    element
      ..attributes["x"] = '$_x'
      ..attributes["y"] = '$_y'
      ..attributes["width"] = '$_width'
      ..attributes["height"] = '$_height'
      ..attributes["rx"] = '0'
      ..attributes["ry"] = '0';
    defaultStyle.forEach((attr, value) => element.attributes[attr] = value);
  }

  remove() {
    element.remove();
  }

  int get x => _x;
  set x (int value) {
    _x = value;
    element.attributes["x"] = '$_x';
  }

  int get y => _y;
  set y (int value) {
    _y = value;
    element.attributes["y"] = '$_y';
  }

  int get width => _width;
  set width (int value) {
    if (opRelativeToCentre) {
      _x = _x + ((_width - value) / 2).floor();
      element.attributes["x"] = '${_x}';
    }
    _width = value;
    element.attributes["width"] = '$_width';
  }

  int get height => _height;
  set height (int value) {
    if (opRelativeToCentre) {
      _x = _x + ((_height - value) / 2).floor();
      element.attributes["x"] = '${_x}';
    }
    _height = value;
    element.attributes["height"] = '$_height';
  }

  String getAttribute(String name) => element.getAttribute(name);
  setAttribute(String name, String value) => element.setAttribute(name, value);
}

