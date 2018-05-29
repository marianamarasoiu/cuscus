part of cuscus.viewmodel;

class GraphicsEditorViewModel extends ObjectWithId {
  view.GraphicsEditorView graphicsEditorView;
  SheetbookViewModel sheetbook;

  GraphicsEditorViewModel(SheetbookViewModel sheetbook) : super() {
    this.sheetbook = sheetbook;
  }

  createView(Element parent) {
    graphicsEditorView = new view.GraphicsEditorView(this);
    parent.append(graphicsEditorView.element);
  }
}