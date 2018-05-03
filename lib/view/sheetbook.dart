part of cuscus.view;

// import 'table.dart' as table;

class SheetbookView {
  DivElement sheetbookElement;
  DivElement tabContainer;
  DivElement addSheetButton;
  DivElement sheetContainer;

  SheetbookViewModel sheetbookViewModel;
  SheetViewModel selectedSheet = null;

  List<SheetView> sheetViews = [];
  
  SheetbookView(this.sheetbookViewModel) {
    addSheetButton = new DivElement()
      ..classes.add('add-sheet-btn')
      ..text = '+'
      ..onClick.listen(((_) => command(InteractionAction.createNewSheet, null)));
    tabContainer = new DivElement()..classes.add('tab-container');
    tabContainer.append(addSheetButton);
    
    sheetContainer = new DivElement()..classes.add('sheet-container');
    
    sheetbookElement = new DivElement()..classes.add('sheetbook');
    sheetbookElement.attributes['data-sheetbook-id'] = '${sheetbookViewModel.id}';
    sheetbookElement.append(tabContainer);
    sheetbookElement.append(sheetContainer);
  }

  SheetView addSheet(SheetViewModel sheet) {
    InputElement input = new InputElement(type: 'radio');
    input..name = 'sheetbook${sheetbookViewModel.id}-tabs'
         ..id = 'sheetbook${sheetbookViewModel.id}-tab${sheet.id}'
         ..value = 'sheetbook${sheetbookViewModel.id}-tab${sheet.id}'
         ..checked = true;
    input.onChange.listen((Event e) => command(InteractionAction.selectSheet, sheet));

    LabelElement label = new LabelElement();
    label..id = 'sheetbook${sheetbookViewModel.id}-label${sheet.id}'
         ..setAttribute('for', input.id)
         ..text = sheet.name;
    label.onDoubleClick.listen((MouseEvent doubleClick) {
      label.contentEditable = 'true';
      String initialName = label.text;
      String newName = label.text;
      label.onKeyUp.listen((e) {
        newName = label.text;
      });
      label.onKeyDown.listen((KeyboardEvent e) {
        if (e.which == 13 && e.shiftKey == false) { // Enter: rename sheet
          window.getSelection().removeAllRanges();
          label.blur();
          label.contentEditable = 'false';
          command(InteractionAction.renameSheet, [sheet, newName]);
          e.preventDefault();
          e.stopPropagation();
        } else if (e.which == 27) { // Esc: cancel name change
          window.getSelection().removeAllRanges();
          label.blur();
          label.contentEditable = 'false';
          label.text = initialName;
          e.preventDefault();
          e.stopPropagation();
        }
      });
    });

    MenuElement contextMenu = new MenuElement();
    DivElement deleteItem = new DivElement();
    deleteItem.text = 'Delete sheet';
    deleteItem.onClick.listen((_) => command(InteractionAction.deleteSheet, sheet));
    contextMenu.append(deleteItem);
    label.contextMenu = contextMenu;

    tabContainer.insertAllBefore([input, label], addSheetButton);

    DivElement sheetElement = new DivElement();
    sheetElement..classes.add('sheet')
                ..id = 'sheetbook${sheetbookViewModel.id}-sheet${sheet.id}'
                ..attributes['data-sheet-id'] = '${sheet.id}';
    SheetView sheetView = new SheetView.from(sheet);
    sheetViews.add(sheetView);
    sheetElement.append(sheetView.sheetElement);

    sheetContainer.append(sheetElement);

    selectedSheet = sheet;
    return sheetView;
  }

  removeSheet(SheetViewModel sheet) {
    tabContainer.querySelector('sheetbook${sheetbookViewModel.id}-tab${sheet.id}').remove();
    tabContainer.querySelector('sheetbook${sheetbookViewModel.id}-label${sheet.id}').remove();
    sheetContainer.querySelector('sheetbook${sheetbookViewModel.id}-sheet${sheet.id}').remove();
    
    SheetView sheetView = sheetViews.singleWhere((sheetView) => sheetView.sheetViewModel == sheet);
    sheetView.remove();
    sheetViews.remove(sheetView);
  }
}
