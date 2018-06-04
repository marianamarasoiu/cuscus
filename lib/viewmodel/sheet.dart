part of cuscus.viewmodel;

// An intermediate abstraction between the execution engine and the UI.
abstract class SheetViewModel extends ObjectWithId {
  int rows;
  int columns;
  String name;
  SheetbookViewModel sheetbook;
  view.SheetView sheetView;

  List<String> activeColumnNames;

  SheetViewModel(this.rows, this.columns, this.name) : super() {
    sheets.add(this);
  }

  String toString() {
    return '$name:$id';
  }
}

class DataSheet extends SheetViewModel {
  DataSheet(rows, columns, name) : super(rows, columns, name) {
    activeColumnNames = getColumns(columns);
  }
}

class WrangleSheet extends SheetViewModel {
  WrangleSheet(rows, columns, name) : super(rows, columns, name) {
    activeColumnNames = getColumns(columns);
  }
}

abstract class VisualisationSheet extends SheetViewModel {
  VisualisationSheet(rows, columns, name) : super(rows, columns, name);
}

class LineSheet extends VisualisationSheet {
  LineSheet(rows, name) : super(rows, null, name) {
    activeColumnNames = _lineProperties.map((item) => item.first).toList();
    columns = activeColumnNames.length;
  }

  bool hasMultipleOptionsForColumn(int column) {
    return _lineProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _lineProperties[column];
  }
  selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }
}

class RectSheet extends VisualisationSheet {
  RectSheet(rows, name) : super(rows, null, name) {
    activeColumnNames = _rectProperties.map((item) => item.first).toList();
    columns = activeColumnNames.length;
  }

  bool hasMultipleOptionsForColumn(int column) {
    return _rectProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _rectProperties[column];
  }
  selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }
}

class EllipseSheet extends VisualisationSheet {
  EllipseSheet(rows, name) : super(rows, null, name) {
    activeColumnNames = _ellipseProperties.map((item) => item.first).toList();
    columns = activeColumnNames.length;
  }

  bool hasMultipleOptionsForColumn(int column) {
    return _ellipseProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _ellipseProperties[column];
  }
  selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }
}

class TextSheet extends VisualisationSheet {
  TextSheet(rows, name) : super(rows, null, name) {
    activeColumnNames = _textProperties.map((item) => item.first).toList();
    columns = activeColumnNames.length;
  }

  bool hasMultipleOptionsForColumn(int column) {
    return _textProperties[column].length > 1;
  }
  List<String> getOptionsForColumn(int column) {
    return _textProperties[column];
  }
  selectOptionForColumn(int column, String option) {
    activeColumnNames[column] = option;
  }
}

// line, rect, ellipse: each row in the spreadsheet represents one element.
final List<List> _lineProperties = [
        ['Start X'],
        ['Start Y'],
        ['End X'],
        ['End Y'],
        ['Rotation'],
        ['Stroke Style'],
        ['Stroke Width'],
        ['Stroke Color'],
        ['Stroke Opacity'],
        ];
final List<List> _rectProperties = [
        ['Width'],
        ['Height'],
        ['Center X', 'Left', 'Right'],
        ['Center Y', 'Top', 'Bottom'],
        ['Corner Radius X'],
        ['Corner Radius Y'],
        ['Rotation'],
        ['Fill Color'],
        ['Fill Opacity'],
        ['Border Style'],
        ['Border Width'],
        ['Border Color'],
        ['Border Opacity'],
        ];
final List<List> _ellipseProperties = [
        ['Radius X'],
        ['Radius Y'],
        ['Center X', 'Left', 'Right'],
        ['Center Y', 'Top', 'Bottom'],
        ['Rotation'],
        ['Fill Color'],
        ['Fill Opacity'],
        ['Border Style'],
        ['Border Width'],
        ['Border Color'],
        ['Border Opacity'],
        ];
final List<List> _textProperties = [
        ['Content'],
        ['Alignment'],
        ['Width'],
        ['Height'],
        ['Center X', 'Left', 'Right'],
        ['Center Y', 'Top', 'Bottom'],
        ['Rotation'],
        ['Text Color'],
        ['Text Opacity'],
        ['Background Color'],
        ['Background Opacity'],
        ['Border Style'],
        ['Border Width'],
        ['Border Color'],
        ['Border Opacity'],
        ];

// path, polyline, polygon: each row represents a point in a series of points.
final List<List> _polylineProperties = [
        ['X'],
        ['Y'],
        ];
final List<List> __polylineSingleProperties = [
        ['Line Type'], // sharp/smooth (only line implemented, for curve line see https://en.wikipedia.org/wiki/Cubic_Hermite_spline#Interpolating_a_data_set)
        ['Fill Color'],
        ['Fill Opacity'],
        ['Stroke Style'],
        ['Stroke Width'],
        ['Stroke Color'],
        ['Stroke Opacity'],
        ];
final List<List> _polygonProperties = [
        ['X'],
        ['Y'],
        ];
final List<List> __polygonSingleProperties = [
        ['Fill Color'],
        ['Fill Opacity'],
        ['Stroke Style'],
        ['Stroke Width'],
        ['Stroke Color'],
        ['Stroke Opacity'],
        ];

final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

List<String> getColumns(int columns) {
  if (columns < _letters.length) {
    return _letters.getRange(0, columns).toList();
  } else {
    List<String> resultLetters = new List.from(_letters);
    _letters.forEach((String letter) {
      resultLetters.addAll(_letters.map((String l) => '$letter$l'));
      if (resultLetters.length > columns) {
        return resultLetters.getRange(0, columns).toList();
      }
    });
    throw "Too many columns.";
  }
}
