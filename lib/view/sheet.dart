part of cuscus.view;

class SheetView {
  SheetViewModel sheetViewModel;
  DivElement sheetElement;
  List<String> columnHeaders;

  TableElement header;
  List<TableCellElement> headerElements = [];
  TableElement index;
  List<TableCellElement> indexElements = [];
  TableElement data;
  List<List<TableCellElement>> dataElements = [];
  DivElement corner;

  // Support for scrolling behaviour
  int _lastKnownLeftScrollPosition = 0;
  int _lastKnownTopScrollPosition = 0;
  bool _ticking = false;

  // Support for selecting a cell (needs to be at sheet level because of scrolling)
  TableCellElement _selectedCell;
  int _selectedCellRow;
  int _selectedCellColumn;
  DivElement _cellSelector;

  SheetView.from(this.sheetViewModel) {
    columnHeaders = getColumns(sheetViewModel.columns);

    sheetElement = new DivElement();
    sheetElement..classes.add('scroll-container');

    header = new TableElement();
    header.classes.add('table-header');

    {
      TableRowElement headerRow = header.addRow();
      headerRow.classes.add('header');
      headerRow.addCell().classes.add('index');
      for (int i = 0; i < sheetViewModel.columns; i++) {
        headerElements.add(headerRow.addCell()
          ..text = columnHeaders[i]);
      }
    }

    index = new TableElement();
    index.classes.add('table-index');

    {
      TableRowElement headerRow = index.addRow();
      headerRow.addCell().classes.add('index');
      for (int i = 0; i < sheetViewModel.rows; i++) {
        indexElements.add(index.addRow().addCell()
          ..classes.add('index')
          ..text = '${i+1}');
      }
    }

    data = new TableElement();
    data.classes.add('table-data');

    {
      for (int i = 0; i < sheetViewModel.rows; i++) {
        TableRowElement row = data.addRow();
        dataElements.add([]);
        for (int i = 0; i < sheetViewModel.columns; i++) {
          dataElements.last.add(row.addCell());
        }
      }
    }
    
    corner = new DivElement();
    corner.style
      ..top = '0'
      ..left = '0';
    corner.classes.add('corner');

    _cellSelector = new DivElement();
    _cellSelector.classes.add("cell-selector");

    sheetElement.append(header);
    sheetElement.append(index);
    sheetElement.append(data);
    sheetElement.append(_cellSelector);
    sheetElement.append(corner);

    // Support for scrolling behaviour
    sheetElement.onScroll.listen((Event scrollEvent) => scrollListener(scrollEvent));
  }

  remove() {
    sheetElement.remove();
  }

  scrollListener(Event scrollEvent) {
    _lastKnownLeftScrollPosition = sheetElement.scrollLeft;
    _lastKnownTopScrollPosition = sheetElement.scrollTop;
    
    if (!_ticking) {
      window.requestAnimationFrame((_) {
        index.style.left = '${_lastKnownLeftScrollPosition}px';
        header.style.top = '${_lastKnownTopScrollPosition}px';
        corner.style.left = '${_lastKnownLeftScrollPosition}px';
        corner.style.top = '${_lastKnownTopScrollPosition}px';
        
        if (_selectedCell != null) {
          _cellSelector.style.top = '${_selectedCell.offset.top + 20}px';
          _cellSelector.style.left = '${_selectedCell.offset.left + 30}px';
        }
        
        _ticking = false;
      });
      _ticking = true;
    }
  }

  TableCellElement get selectedCell => _selectedCell;
  void set selectedCell(TableCellElement cell) {
    _selectedCell = cell;
    if (cell != null) {
      _selectedCellRow = getRowOfCell(cell);
      _selectedCellColumn = getColumnOfCell(cell);
      _cellSelector.style.visibility = 'visible';
      _cellSelector.style.top = '${_selectedCell.offset.top + 20}px';
      _cellSelector.style.left = '${_selectedCell.offset.left + 30}px';
    } else {
      _selectedCell = null;
      _selectedCellRow = -1;
      _selectedCellColumn = -1;
      _cellSelector.style.visibility = 'hidden';
    }
  }
  void selectCellAtCoords(int row, int col) {
    _selectedCell = dataElements[row][col];
    _selectedCellRow = getRowOfCell(_selectedCell);
    _selectedCellColumn = getColumnOfCell(_selectedCell);
    _cellSelector.style.visibility = 'visible';
    _cellSelector.style.top = '${_selectedCell.offset.top + 20}px';
    _cellSelector.style.left = '${_selectedCell.offset.left + 30}px';
  }
  void selectCellBelow(TableCellElement cell) {
    int row = getRowOfCell(cell);
    int col = getColumnOfCell(cell);
    selectCellAtCoords(row + 1, col);
  }
  void selectCellAbove(TableCellElement cell) {
    int row = getRowOfCell(cell);
    int col = getColumnOfCell(cell);
    selectCellAtCoords(max(0, row - 1), col);
  }
  void selectCellRight(TableCellElement cell) {
    int row = getRowOfCell(cell);
    int col = getColumnOfCell(cell);
    selectCellAtCoords(row, col + 1);
  }
  void selectCellLeft(TableCellElement cell) {
    int row = getRowOfCell(cell);
    int col = getColumnOfCell(cell);
    selectCellAtCoords(row, max(0, col - 1));
  }
  int get selectedCellRow => _selectedCellRow;
  int get selectedCellColumn => _selectedCellColumn;

  int getColumnOfCell(TableCellElement cell) {
    for (int i = 0; i < dataElements.length; i++) {
      if (dataElements[i].contains(cell)) {
        return dataElements[i].indexOf(cell);
      }
    }
    throw "Cell $cell not in this table";
  }

  int getRowOfCell(TableCellElement cell) {
    for (int i = 0; i < dataElements.length; i++) {
      if (dataElements[i].contains(cell)) {
        return i;
      }
    }
    throw "Cell $cell not in this table";
  }
}