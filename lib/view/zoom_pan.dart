part of cuscus.view;


var scrollSensitivity = 0.1;
double scale = 1.0;

svg.SvgSvgElement _canvas;
svg.GElement _group;

initZoomPan(svg.SvgSvgElement canvas) {
  _canvas = canvas;
  _group = canvas.querySelector('#zoom-pan-wrapper');
  if (_group == null) {
    throw 'Cannot initialize zoom & pan - wrapper missing';
  }
  _group.transform.baseVal.initialize(canvas.createSvgTransform());
}

var zoomCallbacks = [];

void startZooming(WheelEvent wheelEvent) {
  wheelEvent.preventDefault();
  wheelEvent.stopPropagation();
  var scroll = (wheelEvent.deltaY / 100) * scrollSensitivity;
  scale = 1.0 + scroll;
  
  num mousePosX = wheelEvent.client.x;
  num mousePosY = wheelEvent.client.y;
  
  var oldMatrix = _group.transform.baseVal.consolidate().matrix;
  var point = _canvas.createSvgPoint()
    ..x = mousePosX
    ..y = mousePosY;

  var relativePoint = point.matrixTransform(oldMatrix.inverse());
  var modifier = _canvas.createSvgMatrix().translate(relativePoint.x, relativePoint.y).scale(scale).translate(-relativePoint.x, -relativePoint.y);
  _group.transform.baseVal.initialize(_canvas.createSvgTransformFromMatrix(oldMatrix.multiply(modifier)));

  zoomCallbacks.forEach((callback) => callback(scroll));
}

void startPanning(MouseEvent mouseDown) {
  mouseDown.preventDefault();
  mouseDown.stopPropagation();

  var startMatrix = _group.transform.baseVal.consolidate().matrix;
  num startMousePosX = mouseDown.client.x;
  num startMousePosY = mouseDown.client.y;
  var startPoint = _canvas.createSvgPoint()
    ..x = startMousePosX
    ..y = startMousePosY;
  startPoint = startPoint.matrixTransform(startMatrix.inverse());
  
  StreamSubscription mouseMoveSub;
  StreamSubscription mouseUpSub;
  mouseMoveSub = _canvas.onMouseMove.listen((mouseMove) {
    num mousePosX = mouseMove.client.x;
    num mousePosY = mouseMove.client.y;

    var point = _canvas.createSvgPoint()
      ..x = mousePosX
      ..y = mousePosY;
    point = point.matrixTransform(startMatrix.inverse());

    _group.transform.baseVal.initialize(_canvas.createSvgTransformFromMatrix(startMatrix.translate(point.x - startPoint.x, point.y - startPoint.y)));
  });

  mouseUpSub = _canvas.onMouseUp.listen((mouseUp) {
    _group.transform.baseVal.consolidate();
    mouseMoveSub.cancel();
    mouseUpSub.cancel();
  });
}

svg.Point getRelativePoint(svg.Point point) {
  var matrix = _group.transform.baseVal.consolidate().matrix;
  return point.matrixTransform(matrix.inverse());
  // return point;
}

svg.Point getSvgPoint(num x, num y) {
  return _canvas.createSvgPoint()
    ..x = x
    ..y = y;
}

void resetZoom() {
  _group.transform.baseVal.initialize(_canvas.createSvgTransform());
  zoomCallbacks.forEach((callback) => callback(0));
}

void fitAllZoom() {
  _group.transform.baseVal.initialize(_canvas.createSvgTransform());

  // Scale
  Rectangle<num> viewportBoundingBox = _canvas.getBoundingClientRect();
  Rectangle<num> contentsBoundingBox = _group.getBoundingClientRect();

  if (contentsBoundingBox.width == 0.0 || contentsBoundingBox.height == 0.0)  return;

  var scale = math.min(viewportBoundingBox.width / contentsBoundingBox.width,
                       viewportBoundingBox.height / contentsBoundingBox.height);
  
  var oldMatrix = _group.transform.baseVal.consolidate().matrix;
  var modifier = _canvas.createSvgMatrix().scale(scale);
  _group.transform.baseVal.initialize(_canvas.createSvgTransformFromMatrix(oldMatrix.multiply(modifier)));

  // Pan
  var startMatrix = _group.transform.baseVal.consolidate().matrix;
  contentsBoundingBox = _group.getBoundingClientRect();
  var offsetX = -contentsBoundingBox.left / scale;
  var offsetY = -contentsBoundingBox.top / scale;

  _group.transform.baseVal.initialize(_canvas.createSvgTransformFromMatrix(startMatrix.translate(offsetX, offsetY)));
  contentsBoundingBox = _group.getBoundingClientRect();

  zoomCallbacks.forEach((callback) => callback(scale));
}
