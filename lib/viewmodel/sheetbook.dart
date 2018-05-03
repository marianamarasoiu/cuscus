part of cuscus.viewmodel;

class SheetbookViewModel extends ObjectWithId {
  view.SheetbookView sheetbookView;

  SheetbookViewModel() : super() {
    sheetbooks.add(this);
  }

  createView(Element parent) {
    sheetbookView = new view.SheetbookView(this);
    parent.append(sheetbookView.sheetbookElement);
  }

  addSheet([String type]) {
    if (type != null) {
      SheetViewModel sheet;
      switch (type) {
        case 'LineSheet':
          sheet = new LineSheet(100, 12, 'Line1');
          break;
        case 'RectSheet':
          sheet = new RectSheet(100, 12, 'Rect1');
          break;
        case 'EllipseSheet':
          sheet = new EllipseSheet(100, 12, 'Ellipse1');
          break;
        case 'TextSheet':
          sheet = new TextSheet(100, 12, 'Text1');
          break;
        default:
          sheet = new DataSheet(100, 12, 'Sheet1');
      }
      sheet.view = sheetbookView.addSheet(sheet);
    }
  }
}