part of cuscus.view;

class SheetView {
  SheetViewModel sheetViewModel;
  DivElement sheetElement;

  TableElement header;
  List<TableCellElement> headerElements = [];
  TableElement index;
  List<TableCellElement> indexElements = [];
  TableElement data;
  DivElement corner;

  // Support for scrolling behaviour
  int _lastKnownLeftScrollPosition = 0;
  int _lastKnownTopScrollPosition = 0;
  bool _scrollTicking = false;

  // Support for selecting a cell (needs to be at sheet level because of scrolling)
  CellView selectedCell;
  DivElement cellSelector;

  SheetView(this.sheetViewModel) {
    sheetElement = new DivElement();
    sheetElement..classes.add('scroll-container');

    header = new TableElement();
    header.classes.add('table-header');

    {
      TableRowElement headerRow = header.addRow();
      headerRow.classes.add('header');
      headerRow.addCell().classes.add('index');
      for (int i = 0; i < sheetViewModel.activeColumnNames.length; i++) {
        headerElements.add(headerRow.addCell()
          ..text = sheetViewModel.activeColumnNames[i]);
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
      for (int r = 0; r < sheetViewModel.rows; r++) {
        TableRowElement row = data.addRow();
        for (int c = 0; c < sheetViewModel.columns; c++) {
          sheetViewModel.cells[r][c].createView(row);
        }
      }
    }

    corner = new DivElement();
    corner.style
      ..top = '0'
      ..left = '0';
    corner.classes.add('corner');

    cellSelector = new DivElement();
    cellSelector.classes.add("cell-selector");

    sheetElement.append(header);
    sheetElement.append(index);
    sheetElement.append(data);
    sheetElement.append(cellSelector);
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

    if (!_scrollTicking) {
      window.requestAnimationFrame((_) {
        index.style.left = '${_lastKnownLeftScrollPosition}px';
        header.style.top = '${_lastKnownTopScrollPosition}px';
        corner.style.left = '${_lastKnownLeftScrollPosition}px';
        corner.style.top = '${_lastKnownTopScrollPosition}px';

        if (selectedCell != null) {
          showCellSelector();
        }

        _scrollTicking = false;
      });
      _scrollTicking = true;
    }
  }

  showCellSelector() {
    cellSelector.style
      ..visibility = 'visible'
      ..top = '${selectedCell.cellElement.offset.top + 20}px'
      ..left = '${selectedCell.cellElement.offset.left + 30}px'
      ..width = '${selectedCell.cellElement.client.width}px'
      ..height = '${selectedCell.cellElement.client.height}px';
  }

  hideCellSelector() {
    cellSelector.style.visibility = 'hidden';
  }
}
