part of cuscus.viewmodel;

class SheetbookViewModel extends ObjectWithId {
  view.SheetbookView sheetbookView;
  SheetViewModel selectedSheet;

  SheetbookViewModel() : super();

  createView(Element parent) {
    sheetbookView = new view.SheetbookView(this);
    parent.append(sheetbookView.sheetbookElement);
  }

  SheetViewModel addSheet([String type]) {
    SheetViewModel sheet;
    switch (type) {
      case 'LineSheet':
        sheet = new LineSheet(100, 'Line$sheetCounter');
        break;
      case 'RectSheet':
        sheet = new RectSheet(100, 'Rect$sheetCounter');
        break;
      case 'EllipseSheet':
        sheet = new EllipseSheet(100, 'Ellipse$sheetCounter');
        break;
      case 'TextSheet':
        sheet = new TextSheet(100, 'Text$sheetCounter');
        break;
      default:
        sheet = new DataSheet(100, 12, 'Sheet$sheetCounter');
    }
    view.SheetView sheetView = new view.SheetView(sheet);
    sheet.sheetView = sheetView;
    sheetbookView.addSheet(sheetView);
    selectSheet(sheet);
    return sheet;
  }


  void selectSheet(SheetViewModel sheet) {
    selectedSheet = sheet;
    sheetbookView.selectedSheet = sheet.sheetView;
    sheetbookView.showSelectedSheet();
  }
}

int sheetNumber = 1;
get sheetCounter => sheetNumber++;
