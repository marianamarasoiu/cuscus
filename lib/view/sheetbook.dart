part of cuscus.view;

class SheetbookView {
  DivElement sheetbookElement;
  DivElement tabContainer;
  DivElement addSheetButton;
  DivElement sheetContainer;

  viewmodel.SheetbookViewModel sheetbookViewModel;
  SheetView selectedSheet;

  List<SheetView> sheetViews = [];

  SheetbookView(this.sheetbookViewModel) {
    // Create the sheetbook
    addSheetButton = new DivElement()
      ..classes.add('add-sheet-btn')
      ..text = '+'
      ..onClick.listen(((_) => viewmodel.appController.command(viewmodel.UIAction.createNewSheet, sheetbookViewModel)));
    tabContainer = new DivElement()..classes.add('tab-container');
    tabContainer.append(addSheetButton);

    sheetContainer = new DivElement()..classes.add('sheet-container');

    sheetbookElement = new DivElement()..classes.add('sheetbook');
    sheetbookElement.attributes['data-sheetbook-id'] = '${sheetbookViewModel.id}';
    sheetbookElement.append(tabContainer);
    sheetbookElement.append(sheetContainer);

    // Add the sheetbook to the UI
    DivElement container = sheetbooksBox.createNewInnerBox();
    container.append(sheetbookElement);
  }

  addSheet(SheetView sheet) {
    viewmodel.SheetViewModel sheetViewModel = sheet.sheetViewModel;
    InputElement input = new InputElement(type: 'radio');
    input..name = 'sheetbook${sheetbookViewModel.id}-tabs'
         ..id = 'sheetbook${sheetbookViewModel.id}-tab${sheetViewModel.id}'
         ..value = 'sheetbook${sheetbookViewModel.id}-tab${sheetViewModel.id}'
         ..checked = true;

    LabelElement label = new LabelElement();
    label..id = 'sheetbook${sheetbookViewModel.id}-label${sheetViewModel.id}'
         ..setAttribute('for', input.id)
         ..text = sheetViewModel.name;
    label.onDoubleClick.listen((Event doubleClick) {
      label.contentEditable = 'true';
      String initialName = label.text;
      String newName = label.text;

      viewmodel.appController.command(viewmodel.UIAction.startRenameSheet, sheetViewModel);

      label.onKeyUp.listen((e) {
        newName = label.text;
      });

      label.onKeyDown.listen((KeyboardEvent e) {
        if (e.which == 13 && e.shiftKey == false) { // Enter: rename sheet
          window.getSelection().removeAllRanges();
          label.blur();
          label.contentEditable = 'false';
          viewmodel.appController.command(viewmodel.UIAction.endRenameSheet, [sheetViewModel, newName]);
          e.preventDefault();
          e.stopPropagation();
        } else if (e.which == 27) { // Esc: cancel name change
          window.getSelection().removeAllRanges();
          label.blur();
          label.contentEditable = 'false';
          label.text = initialName;
          viewmodel.appController.command(viewmodel.UIAction.endRenameSheet, null);
          e.preventDefault();
          e.stopPropagation();
        }
      });
    });
    label.onClick.listen((_) => sheetViewModel.focus());

    // MenuElement contextMenu = new MenuElement();
    // DivElement deleteItem = new DivElement();
    // deleteItem.text = 'Delete sheet';
    // deleteItem.onClick.listen((_) => viewmodel.appController.command(viewmodel.UIAction.deleteSheet, sheetViewModel));
    // contextMenu.append(deleteItem);
    // label.contextMenu = contextMenu;

    tabContainer.insertAllBefore([input, label], addSheetButton);

    DivElement sheetElementWrapper = new DivElement();
    sheetElementWrapper..classes.add('sheet')
                ..id = 'sheetbook${sheetbookViewModel.id}-sheet${sheetViewModel.id}'
                ..attributes['data-sheet-id'] = '${sheetViewModel.id}';
    sheetViews.add(sheet);
    sheetElementWrapper.append(sheet.sheetElement);

    sheetContainer.append(sheetElementWrapper);
  }

  focusOnSelectedSheet() {
    (querySelector('input#sheetbook${sheetbookViewModel.id}-tab${selectedSheet.sheetViewModel.id}') as InputElement).checked = true;
    sheetViews.forEach((sheetView) => sheetView.sheetElement.parent.classes.remove('selected'));
    selectedSheet.sheetElement.parent.classes.add('selected');
  }

  removeSheet(viewmodel.SheetViewModel sheet) {
    tabContainer.querySelector('sheetbook${sheetbookViewModel.id}-tab${sheet.id}').remove();
    tabContainer.querySelector('sheetbook${sheetbookViewModel.id}-label${sheet.id}').remove();
    sheetContainer.querySelector('sheetbook${sheetbookViewModel.id}-sheet${sheet.id}').remove();

    SheetView sheetView = sheetViews.singleWhere((sheetView) => sheetView.sheetViewModel == sheet);
    sheetView.remove();
    sheetViews.remove(sheetView);
  }
}
