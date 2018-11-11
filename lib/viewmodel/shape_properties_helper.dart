part of cuscus.viewmodel;

/******
 * Rect
 */

enum Rect {
  x,
  y,
  width,
  height,
  rx,
  ry,
  fillColor,
  fillOpacity,
  strokeColor,
  strokeWidth,
  strokeOpacity,
  opacity
}

const Map<Rect, String> rectPropertyToColumnName = const {
  Rect.width: 'Width',
  Rect.height: 'Height',
  Rect.x: 'X',
  Rect.y: 'Y',
  Rect.rx: 'CornerRadiusX',
  Rect.ry: 'CornerRadiusY',
  Rect.fillColor: 'FillColor',
  Rect.fillOpacity: 'FillOpacity',
  Rect.strokeColor: 'BorderColor',
  Rect.strokeWidth: 'BorderWidth',
  Rect.strokeOpacity: 'BorderOpacity',
  Rect.opacity: 'Opacity'
};

Map<String, Rect> _columnNameToRectProperty = {};
Map<String, Rect> get columnNameToRectProperty {
  if (_columnNameToRectProperty.isEmpty) {
    rectPropertyToColumnName.forEach((rect, column) => _columnNameToRectProperty[column] = rect);
  }
  return _columnNameToRectProperty;
}

const Map<Rect, String> rectPropertyToSvgProperty = const {
  Rect.width: 'width',
  Rect.height: 'height',
  Rect.x: 'x',
  Rect.y: 'y',
  Rect.rx: 'rx',
  Rect.ry: 'ry',
  Rect.fillColor: 'fill',
  Rect.fillOpacity: 'fill-opacity',
  Rect.strokeColor: 'stroke',
  Rect.strokeWidth: 'stroke-width',
  Rect.strokeOpacity: 'stroke-opacity',
  Rect.opacity: 'opacity'
};

Map<String, Rect> _svgPropertyToRectProperty = {};
Map<String, Rect> get svgPropertyToRectProperty {
  if (_svgPropertyToRectProperty.isEmpty) {
    rectPropertyToSvgProperty.forEach((rect, property) => _svgPropertyToRectProperty[property] = rect);
  }
  return _svgPropertyToRectProperty;
}


/******
 * Line
 */

enum Line {
  x1,
  y1,
  x2,
  y2,
  strokeColor,
  strokeWidth,
  strokeOpacity,
}

const Map<Line, String> linePropertyToColumnName = const {
  Line.x1: 'StartX',
  Line.y1: 'StartY',
  Line.x2: 'EndX',
  Line.y2: 'EndY',
  Line.strokeColor: 'Color',
  Line.strokeWidth: 'Width',
  Line.strokeOpacity: 'Opacity',
};

Map<String, Line> _columnNameToLineProperty = {};
Map<String, Line> get columnNameToLineProperty {
  if (_columnNameToLineProperty.isEmpty) {
    linePropertyToColumnName.forEach((line, column) => _columnNameToLineProperty[column] = line);
  }
  return _columnNameToLineProperty;
}

const Map<Line, String> linePropertyToSvgProperty = const {
  Line.x1: 'x1',
  Line.y1: 'y1',
  Line.x2: 'x2',
  Line.y2: 'y2',
  Line.strokeColor: 'stroke',
  Line.strokeWidth: 'stroke-width',
  Line.strokeOpacity: 'stroke-opacity',
};

Map<String, Line> _svgPropertyToLineProperty = {};
Map<String, Line> get svgPropertyToLineProperty {
  if (_svgPropertyToLineProperty.isEmpty) {
    linePropertyToSvgProperty.forEach((line, property) => _svgPropertyToLineProperty[property] = line);
  }
  return _svgPropertyToLineProperty;
}

/******
 * Ellipse
 */

enum Ellipse {
  cx,
  cy,
  rx,
  ry,
  fillColor,
  fillOpacity,
  strokeColor,
  strokeWidth,
  strokeOpacity,
  opacity
}

const Map<Ellipse, String> ellipsePropertyToColumnName = const {
  Ellipse.cx: 'CenterX',
  Ellipse.cy: 'CenterY',
  Ellipse.rx: 'RadiusX',
  Ellipse.ry: 'RadiusY',
  Ellipse.fillColor: 'FillColor',
  Ellipse.fillOpacity: 'FillOpacity',
  Ellipse.strokeColor: 'BorderColor',
  Ellipse.strokeWidth: 'BorderWidth',
  Ellipse.strokeOpacity: 'BorderOpacity',
  Ellipse.opacity: 'Opacity'
};

Map<String, Ellipse> _columnNameToEllipseProperty = {};
Map<String, Ellipse> get columnNameToEllipseProperty {
  if (_columnNameToEllipseProperty.isEmpty) {
    ellipsePropertyToColumnName.forEach((ellipse, column) => _columnNameToEllipseProperty[column] = ellipse);
  }
  return _columnNameToEllipseProperty;
}

const Map<Ellipse, String> ellipsePropertyToSvgProperty = const {
  Ellipse.cx: 'cx',
  Ellipse.cy: 'cy',
  Ellipse.rx: 'rx',
  Ellipse.ry: 'ry',
  Ellipse.fillColor: 'fill',
  Ellipse.fillOpacity: 'fill-opacity',
  Ellipse.strokeColor: 'stroke',
  Ellipse.strokeWidth: 'stroke-width',
  Ellipse.strokeOpacity: 'stroke-opacity',
  Ellipse.opacity: 'opacity'
};

Map<String, Ellipse> _svgPropertyToEllipseProperty = {};
Map<String, Ellipse> get svgPropertyToEllipseProperty {
  if (_svgPropertyToEllipseProperty.isEmpty) {
    ellipsePropertyToSvgProperty.forEach((ellipse, property) => _svgPropertyToEllipseProperty[property] = ellipse);
  }
  return _svgPropertyToEllipseProperty;
}


/******
 * Text
 */

enum Text {
  content,
  x,
  y,
  fillColor,
  fillOpacity,
  strokeColor,
  strokeWidth,
  strokeOpacity,
  opacity
}

const Map<Text, String> textPropertyToColumnName = const {
  Text.content: 'Content',
  Text.x: 'X',
  Text.y: 'Y',
  Text.fillColor: 'FillColor',
  Text.fillOpacity: 'FillOpacity',
  Text.strokeColor: 'BorderColor',
  Text.strokeWidth: 'BorderWidth',
  Text.strokeOpacity: 'BorderOpacity',
  Text.opacity: 'Opacity'
};

Map<String, Text> _columnNameToTextProperty = {};
Map<String, Text> get columnNameToTextProperty {
  if (_columnNameToTextProperty.isEmpty) {
    textPropertyToColumnName.forEach((text, column) => _columnNameToTextProperty[column] = text);
  }
  return _columnNameToTextProperty;
}

const Map<Text, String> textPropertyToSvgProperty = const {
  Text.content: 'text',
  Text.x: 'x',
  Text.y: 'y',
  Text.fillColor: 'fill',
  Text.fillOpacity: 'fill-opacity',
  Text.strokeColor: 'stroke',
  Text.strokeWidth: 'stroke-width',
  Text.strokeOpacity: 'stroke-opacity',
  Text.opacity: 'opacity'
};

Map<String, Text> _svgPropertyToTextProperty = {};
Map<String, Text> get svgPropertyToTextProperty {
  if (_svgPropertyToTextProperty.isEmpty) {
    textPropertyToSvgProperty.forEach((text, property) => _svgPropertyToTextProperty[property] = text);
  }
  return _svgPropertyToTextProperty;
}
