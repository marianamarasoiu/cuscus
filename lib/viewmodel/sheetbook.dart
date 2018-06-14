part of cuscus.viewmodel;

class SheetbookViewModel extends ObjectWithId {
  view.SheetbookView sheetbookView;
  SheetViewModel selectedSheet;

  SheetbookViewModel() : super();

  createView(Element parent) {
    sheetbookView = new view.SheetbookView(this);
    parent.append(sheetbookView.sheetbookElement);
  }

  SheetViewModel addSheet([String type]) { // TODO: replace the type with an enum
    SheetViewModel sheet;
    view.SheetView sheetView;
    switch (type) {
      case 'LineSheet':
        sheet = new LineSheet(100, 'Line$sheetCounter');
        sheetView = new view.GraphicsSheetView(sheet);
        break;
      case 'RectSheet':
        sheet = new RectSheet(100, 'Rect$sheetCounter');
        sheetView = new view.GraphicsSheetView(sheet);
        break;
      case 'EllipseSheet':
        sheet = new EllipseSheet(100, 'Ellipse$sheetCounter');
        sheetView = new view.GraphicsSheetView(sheet);
        break;
      case 'TextSheet':
        sheet = new TextSheet(100, 'Text$sheetCounter');
        sheetView = new view.GraphicsSheetView(sheet);
        break;
      default:
        sheet = new DataSheet(100, 12, 'Sheet$sheetCounter');
        sheetView = new view.SheetView(sheet);
    }
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
