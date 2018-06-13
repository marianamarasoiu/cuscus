part of cuscus.viewmodel;

class LayerSheetFactory {
  GraphicsSheetViewModel sheet;
  LayerViewModel layer;

  factory LayerSheetFactory(Shape type) {
    switch (type) {
      case Shape.rect:
        GraphicsSheetViewModel sheet = graphicsSheetbookViewModel.addSheet('RectSheet');
        LayerViewModel layer = graphicsEditorViewModel.addLayer('RectLayer');

        sheet.layerViewModel = layer;
        layer.graphicsSheetViewModel = sheet;

        return new LayerSheetFactory._internal(sheet, layer);
        break;
    }
    throw 'Unrecognised shape type, got $type';
  }

  LayerSheetFactory._internal(this.sheet, this.layer);
}
