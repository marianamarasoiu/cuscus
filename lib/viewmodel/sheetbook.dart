part of cuscus.viewmodel;

class SheetbookViewModel extends ObjectWithId {
  view.SheetbookView sheetbookView;

  SheetbookType type;
  /// This field is set only when the [type] is [SheetbookType.graphics].
  LayerbookViewModel layerbook;

  List<SheetViewModel> sheets = [];

  static int _sheetNumber = 1;
  static get _sheetCounter => _sheetNumber++;
  static void clear() => _sheetNumber = 1;

  SheetbookViewModel([this.type = SheetbookType.data]) : super() {
    sheetbookView = new view.SheetbookView(this);
    if (type == SheetbookType.graphics) {
      layerbook = new LayerbookViewModel(this);
      layerbook.focus();
    }
  }

  SheetbookViewModel.load(sheetbookInfo) : super(sheetbookInfo["sheetbook-id"]) {
    type = getSheetbookType(sheetbookInfo['type']);
    sheetbookView = new view.SheetbookView(this);

    if (type == SheetbookType.graphics) {
      layerbook = new LayerbookViewModel(this);
      layerbook.focus();
    }

    sheetbookInfo["sheets"].forEach((sheetInfo) {
      SheetViewModel sheet = new SheetViewModel.load(sheetInfo, this);
      sheets.add(sheet);
      sheet.focus();
    });
  }

  SheetViewModel addSheet([GraphicMarkType type]) {
    SheetViewModel sheet = new SheetViewModel(this, type);
    sheets.add(sheet);
    sheet.focus();
    return sheet;
  }

  Map save() {
    return {
      "sheetbook-id": id,
      "type": type.toString(),
      "sheets": sheets.map((sheet) => sheet.save()).toList(),
    };
  }
}
