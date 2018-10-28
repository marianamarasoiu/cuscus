import 'dart:async';
import 'dart:html';
import 'dart:math';

/**
 * UI elements that make the interface work rather than be central to its functionality.
 */

class Box {
  DivElement element;

  List<Element> innerBoxes = [];
  List<Splitter> splitters = [];
  int splitterSize = 6;

  Box(this.element) {
    element.classes.toggle('box', true);
    if (!isVertical && !isHorizontal) {
      element.setAttribute('layout', '');
      element.setAttribute('vertical', '');
    }
    innerBoxes = element.children.where((e) => e.classes.contains('box')).toList();
    splitters = element.children.where((e) => e.classes.contains('splitter')).toList()
                                .map((e) => new Splitter(e)).toList();
    _init();
  }

  Box.vertical() {
    element = new DivElement();
    element.classes.add('box');
    element.setAttribute('layout', '');
    element.setAttribute('vertical', '');
  }

  Box.horizontal() {
    element = new DivElement();
    element.classes.add('box');
    element.setAttribute('layout', '');
    element.setAttribute('horizontal', '');
  }

  get isVertical => element.attributes.containsKey('vertical');
  get isHorizontal => element.attributes.containsKey('horizontal');

  _init() {
    element.classes.toggle('flex', true);

    num width = num.parse(element.getComputedStyle().width.replaceAll('px', ''));
    num height = num.parse(element.getComputedStyle().height.replaceAll('px', ''));

    num innerBoxWidth = (width - splitterSize * splitters.length) / innerBoxes.length;
    num innerBoxHeight = (height - splitterSize * splitters.length) / innerBoxes.length;
    num innerBoxWidthPercent = innerBoxWidth / width * 100;
    num innerBoxHeightPercent = innerBoxHeight / height * 100;

    innerBoxes.forEach((Element innerBox) {
      if (isVertical) {
        innerBox.style.height = '${innerBoxHeightPercent}%';
      } else {
        innerBox.style.width = '${innerBoxWidthPercent}%';
      }
    });
  }

  /// Creates a new inner box.
  /// [index] is given relative to the number of inner boxes, not including splitters.
  /// If [index] is negative, it creates a new box it at the beginning.
  /// If [index] is null or larger than the list, it creates a new box it at the end.
  DivElement createNewInnerBox([int index]) {
    DivElement innerBox = new DivElement();
    innerBox.classes.add('box');

    index = (index == null || index > innerBoxes.length) ? innerBoxes.length : index < 0 ? 0 : index;
    if (innerBoxes.length == 0) {
      // add just the inner box
      innerBoxes.add(innerBox);
      element.append(innerBox);
    } else if (index == 0) {
      // add the box followed by a splitter
      innerBoxes.insert(0, innerBox);
      Splitter splitter = isVertical ? new Splitter.horizontal() : new Splitter.vertical();
      splitters.insert(0, splitter);
      element.insertAllBefore([innerBox, splitter.element], element.firstChild);
    } else {
      // add a splitter followed by a box
      bool insertAtEnd = index == innerBoxes.length;
      innerBoxes.insert(index, innerBox);
      Splitter splitter = isVertical ? new Splitter.horizontal() : new Splitter.vertical();
      splitters.insert(index - 1, splitter);
      if (insertAtEnd) {
        element.append(splitter.element);
        element.append(innerBox);
      } else {
        element.insertAllBefore([splitter.element, innerBox], element.children.elementAt(2*index-1));
      }
    }

    num width = num.parse(element.getComputedStyle().width.replaceAll('px', ''));
    num height = num.parse(element.getComputedStyle().height.replaceAll('px', ''));

    num innerBoxWidth = (width - splitterSize * splitters.length) / innerBoxes.length;
    num innerBoxHeight = (height - splitterSize * splitters.length) / innerBoxes.length;
    num newInnerBoxWidthPercent = innerBoxWidth / width * 100;
    num newInnerBoxHeightPercent = innerBoxHeight / height * 100;
    num restInnerBoxesWidthPercent = 100 - newInnerBoxWidthPercent;
    num restInnerBoxesHeightPercent = 100 - newInnerBoxHeightPercent;

    if (isVertical) {
      innerBox.style.height = '${newInnerBoxHeightPercent}%';
    } else {
      innerBox.style.width = '${newInnerBoxWidthPercent}%';
    }

    innerBoxes.where((box) => box != innerBox).forEach((Element box) {
      if (isVertical) {
        num heightPercent = num.parse(box.style.height.replaceAll('%', ''));
        box.style.height = '${heightPercent / 100 * restInnerBoxesHeightPercent}%';
      } else {
        num widthPercent = num.parse(box.style.width.replaceAll('%', ''));
        box.style.width = '${widthPercent / 100 * restInnerBoxesWidthPercent}%';
      }
    });
    return innerBox;
  }
}

/* With some inspiration from https://github.com/dart-lang/dart-pad/blob/master/lib/elements/elements.dart */
class Splitter {
  DivElement element;

  StreamSubscription _mouseMoveStream;
  StreamSubscription _mouseUpStream;

  Splitter(this.element) {
    _init();
  }

  Splitter.vertical() {
    element = new DivElement();
    element.setAttribute('vertical', '');
    _init();
  }

  Splitter.horizontal() {
    element = new DivElement();
    element.setAttribute('horizontal', '');
    _init();
  }

  get isVertical => element.attributes.containsKey('vertical');
  get isHorizontal => element.attributes.containsKey('horizontal');

  _init() {
    element.classes.toggle('splitter', true);

    if (element.querySelector('div.inner') == null) {
      DivElement inner = new DivElement();
      inner.classes.add('inner');
      element.append(inner);
    }
    if (element.querySelectorAll('div.inner div.dot').isEmpty) {
      element.querySelector('div.inner').appendHtml('<div class="dot"></div><div class="dot"></div><div class="dot"></div><div class="dot"></div>');
    }

    element.onMouseDown.listen((MouseEvent mouseDown) {
      mouseDown.preventDefault();
      mouseDown.stopPropagation();
      Point mouseDownClient = mouseDown.client;
      Point outerBoxSize = new Point(
        num.parse(element.parent.getComputedStyle().width.replaceAll('px', '')),
        num.parse(element.parent.getComputedStyle().height.replaceAll('px', '')));
      Point previousElementMinSize = minDimensions(previousElement);
      Point previousElementMinSizePercent = new Point(
        previousElementMinSize.x / outerBoxSize.x * 100,
        previousElementMinSize.y / outerBoxSize.y * 100);
      Point nextElementMinSize = minDimensions(nextElement);
      Point nextElementMinSizePercent = new Point(
        nextElementMinSize.x / outerBoxSize.x * 100,
        nextElementMinSize.y / outerBoxSize.y * 100);

      num previousElementWidthPercent;
      num previousElementHeightPercent;
      num nextElementWidthPercent;
      num nextElementHeightPercent;
      if (isVertical) {
        previousElementWidthPercent = num.parse(previousElement.style.width.replaceAll('%', ''));
        nextElementWidthPercent = num.parse(nextElement.style.width.replaceAll('%', ''));
      } else {
        previousElementHeightPercent = num.parse(previousElement.style.height.replaceAll('%', ''));
        nextElementHeightPercent = num.parse(nextElement.style.height.replaceAll('%', ''));
      }

      _mouseMoveStream = document.onMouseMove.listen((MouseEvent mouseMove) {
        Point mouseDelta = mouseMove.client - mouseDownClient;
        Point deltaPercent = new Point(
          mouseDelta.x / outerBoxSize.x * 100,
          mouseDelta.y / outerBoxSize.y * 100);

        // compute the correct position
        if (isVertical) {
          bool previousAdjusted = false;
          bool nextAdjusted = false;
          if (previousElementWidthPercent + deltaPercent.x < previousElementMinSizePercent.x) {
            deltaPercent = new Point(
              previousElementMinSizePercent.x - previousElementWidthPercent,
              deltaPercent.y);
            previousAdjusted = true;
          }
          if (nextElementWidthPercent - deltaPercent.x < nextElementMinSizePercent.x) {
            deltaPercent = new Point(
              -nextElementMinSizePercent.x + nextElementWidthPercent,
              deltaPercent.y);
            nextAdjusted = true;
          }
          if (!previousAdjusted || !nextAdjusted) {
            previousElement.style.width = '${previousElementWidthPercent + deltaPercent.x}%';
            previousElement.style.flex = 'unset';
            nextElement.style.width = '${nextElementWidthPercent - deltaPercent.x}%';
            nextElement.style.flex = 'unset';
          }
        } else {
          bool previousAdjusted = false;
          bool nextAdjusted = false;
          if (previousElementHeightPercent + deltaPercent.y < previousElementMinSizePercent.y) {
            deltaPercent = new Point(
              deltaPercent.x,
              previousElementMinSizePercent.y - previousElementHeightPercent);
            previousAdjusted = true;
          }
          if (nextElementHeightPercent - deltaPercent.y < nextElementMinSizePercent.y) {
            deltaPercent = new Point(
              deltaPercent.x,
              -nextElementMinSizePercent.y + nextElementHeightPercent);
            nextAdjusted = true;
          }
          if (!previousAdjusted || !nextAdjusted) {
            previousElement.style.height = '${previousElementHeightPercent + deltaPercent.y}%';
            previousElement.style.flex = 'unset';
            nextElement.style.height = '${nextElementHeightPercent - deltaPercent.y}%';
            nextElement.style.flex = 'unset';
          }
        }
      });

      _mouseUpStream = document.onMouseUp.listen((MouseEvent mouseUp) {
        _mouseMoveStream.cancel();
        _mouseUpStream.cancel();
      });
    });
  }

  Element get previousElement => element.previousElementSibling;
  Element get nextElement => element.nextElementSibling;
}

Point minDimensions(Element element) {
  int minWidth = 0;
  int minHeight = 0;
  String w = element.getComputedStyle().minWidth.replaceAll('px', '');
  String h = element.getComputedStyle().minHeight.replaceAll('px', '');
  if (w.isNotEmpty && w != 'auto' && w != 'max-content' && w != 'min-content' && w != 'fit-content' && w != 'fit-available') {
    minWidth = int.parse(w);
  }
  if (h.isNotEmpty && h != 'auto' && h != 'max-content' && h != 'min-content' && h != 'fit-content' && h != 'fit-available') {
    minHeight = int.parse(h);
  }
  return new Point(minWidth, minHeight);
}
