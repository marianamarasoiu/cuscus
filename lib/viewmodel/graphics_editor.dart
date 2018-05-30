part of cuscus.viewmodel;

class GraphicsEditorViewModel extends ObjectWithId {
  view.GraphicsEditorView graphicsEditorView;
  SheetbookViewModel sheetbook;

  GraphicsEditorViewModel(SheetbookViewModel sheetbook) : super() {
    this.sheetbook = sheetbook;
  }

  createView() {
    graphicsEditorView = new view.GraphicsEditorView(this);
  }
}