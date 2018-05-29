part of cuscus.viewmodel;

class SheetbookViewModel extends ObjectWithId {
  view.SheetbookView sheetbookView;

  SheetbookViewModel() : super();

  createView(Element parent) {
    sheetbookView = new view.SheetbookView(this);
    parent.append(sheetbookView.sheetbookElement);
  }

  addSheet([String type]) {
    if (type != null) {
      SheetViewModel sheet;
      switch (type) {
        case 'LineSheet':
          sheet = new LineSheet(100, 12, 'Line$sheetCounter');
          break;
        case 'RectSheet':
          sheet = new RectSheet(100, 12, 'Rect$sheetCounter');
          break;
        case 'EllipseSheet':
          sheet = new EllipseSheet(100, 12, 'Ellipse$sheetCounter');
          break;
        case 'TextSheet':
          sheet = new TextSheet(100, 12, 'Text$sheetCounter');
          break;
        default:
          sheet = new DataSheet(100, 12, 'Sheet$sheetCounter');
      }
      sheet.view = sheetbookView.addSheet(sheet);
    }
  }

}

int sheetNumber = 1;
get sheetCounter => sheetNumber++;