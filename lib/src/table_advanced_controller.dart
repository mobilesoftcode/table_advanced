import 'package:flutter/material.dart';

class TableAdvancedController<T> extends ChangeNotifier {
  final List<T> items;
  final Future<List<T>?> Function(int page, int pageSize)? onChangePage;
  final void Function(List<T> items)? onCheckItems;

  TableAdvancedController({
    required this.items,
    int? rowsCountToPaginate,
    this.onCheckItems,
    this.onChangePage,
    this.rowsToShow = 10,
  }) {
    this.rowsCountToPaginate = rowsCountToPaginate ?? items.length;
    pageCount = _evaluatePageCount(
        rowsToShow: rowsToShow, rowsCount: this.rowsCountToPaginate);
    setItems(items);
  }

  late int rowsCountToPaginate;
  int rowsToShow;
  int currentPage = 1;
  late int pageCount;

  late List<T> dataItems;
  late List<T> dataItemsToShow;
  final List<T> checkedItems = [];

  int _evaluatePageCount({required int rowsToShow, required int rowsCount}) {
    var pages = rowsCount ~/ rowsToShow;
    if (rowsCount % rowsToShow != 0) {
      pages++;
    }
    return pages;
  }

  void checkItems(List<T> items,
      {bool checkAll = false, required bool checked}) {
    if (checkedItems.length == dataItemsToShow.length && checkAll) {
      checkedItems.clear();
    } else {
      for (var element in items) {
        if (checkedItems.contains(element)) {
          if (!checkAll) {
            checkedItems.remove(element);
          }
        } else {
          checkedItems.add(element);
        }
      }
    }

    onCheckItems?.call(List.of(checkedItems));
    notifyListeners();
  }

  void setRowsCount(int count) {
    rowsCountToPaginate = count;
    pageCount = _evaluatePageCount(
        rowsToShow: rowsToShow, rowsCount: rowsCountToPaginate);
    notifyListeners();
  }

  void goToNextPage() {
    goToPage(currentPage + 1);
  }

  void goToPreviousPage() {
    goToPage(currentPage - 1);
  }

  void goToPage(int page, {bool pageStartsFromZero = false}) async {
    currentPage = page + (pageStartsFromZero ? 1 : 0);
    var newItems = await onChangePage?.call(currentPage, rowsToShow);
    setItems(newItems ?? dataItems, replace: newItems != null, reload: true);
  }

  void changeNumberOfRowsToShow(int number) async {
    currentPage = 1;
    rowsToShow = number;
    pageCount = _evaluatePageCount(
        rowsToShow: rowsToShow, rowsCount: rowsCountToPaginate);
    var newData = await onChangePage?.call(currentPage, rowsToShow);
    setItems(newData ?? dataItems, replace: newData != null, reload: true);
  }

  void setItems(List<T> items, {bool replace = false, bool reload = false}) {
    this.dataItems = List.of(items);
    dataItemsToShow = _evaluateRowsToShow(replace: replace);

    if (reload) {
      notifyListeners();
    }
  }

  List<T> _evaluateRowsToShow({bool replace = false}) {
    if (replace) {
      return List.of(dataItems);
    }
    var initialIndexToSplit = (currentPage - 1) * rowsToShow;
    if (dataItems.length < initialIndexToSplit) {
      return [];
    }
    List<T> rows = List.of(dataItems.sublist(initialIndexToSplit));

    if (rowsToShow < rows.length) {
      rows = List.of(rows.sublist(0, rowsToShow));
    }
    return rows;
  }
}
