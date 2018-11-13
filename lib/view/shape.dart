part of cuscus.view;

abstract class ShapeView {
  viewmodel.ShapeViewModel shapeViewModel;
  svg.SvgElement element;

  String getAttribute(String name) => element.getAttribute(name);
  setAttribute(String name, String value) => element.setAttribute(name, value);
}

abstract class RectShapeView extends ShapeView {
  num get x;
  num get y;
  num get width;
  num get height;
}

abstract class LineShapeView extends ShapeView {
  num get x1;
  num get y1;
  num get x2;
  num get y2;
}

class RectView extends RectShapeView {
  RectView(viewmodel.RectShapeViewModel shapeViewModel) {
    this.shapeViewModel = shapeViewModel;
    element = new svg.RectElement();
    element.attributes['data-index'] = '${shapeViewModel.index}';
    element.classes.add('shape');

    shapeViewModel.properties.forEach(
      (property, value) => element.attributes[viewmodel.rectPropertyToSvgProperty[property]] = value.toString());
  }

  num get x => shapeViewModel.properties[viewmodel.Rect.x];
  num get y => shapeViewModel.properties[viewmodel.Rect.y];
  num get width => shapeViewModel.properties[viewmodel.Rect.width];
  num get height => shapeViewModel.properties[viewmodel.Rect.height];
}

class TextView extends RectShapeView {
  TextView(viewmodel.TextViewModel shapeViewModel) {
    this.shapeViewModel = shapeViewModel;
    element = new svg.TextElement();
    element.attributes['data-index'] = '${shapeViewModel.index}';
    element.classes.add('shape');

    shapeViewModel.properties.forEach(
      (property, value) => element.attributes[viewmodel.textPropertyToSvgProperty[property]] = value.toString());
    element.text = shapeViewModel.properties[viewmodel.Text.content].toString();
  }

  num get x => shapeViewModel.properties[viewmodel.Text.x];
  num get y => shapeViewModel.properties[viewmodel.Text.y] - renderedTextSize()['height'];
  num get width => renderedTextSize()['width'];
  num get height => renderedTextSize()['height'];
  String get content => shapeViewModel.properties[viewmodel.Text.content].toString();

  setAttribute(String name, String value) {
    if (name == viewmodel.textPropertyToSvgProperty[viewmodel.Text.content]) {
      element.text = value;
      return;
    }
    element.setAttribute(name, value);
  }

  Map<String, num> renderedTextSize() {
    svg.SvgSvgElement hiddenCanvas = new svg.SvgSvgElement();
    hiddenCanvas.style.visibility = 'hidden';
    document.body.append(hiddenCanvas);
    
    svg.TextElement text = new svg.TextElement();
    text
      ..style.visibility = 'hidden'
      ..text = element.text;
    hiddenCanvas.append(text);

    var bRect = text.getBoundingClientRect();
    hiddenCanvas.remove();

    return {
      'width': bRect.width,
      'height': bRect.height
    };
  }
}

class LineView extends LineShapeView {
  LineView(viewmodel.LineShapeViewModel shapeViewModel) {
    this.shapeViewModel = shapeViewModel;
    element = new svg.LineElement();
    element.attributes['data-index'] = '${shapeViewModel.index}';
    element.classes.add('shape');

    shapeViewModel.properties.forEach((property, value) {
      element.attributes[viewmodel.linePropertyToSvgProperty[property]] = value.toString();
    });
  }

  num get x1 => shapeViewModel.properties[viewmodel.Line.x1];
  num get y1 => shapeViewModel.properties[viewmodel.Line.y1];
  num get x2 => shapeViewModel.properties[viewmodel.Line.x2];
  num get y2 => shapeViewModel.properties[viewmodel.Line.y2];
}
