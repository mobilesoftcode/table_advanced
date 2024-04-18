import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum TableMode {
  plain,
  paginationScroll,
  paginationPage,
}

/// Controller to manage content and properties of [TableAdvanced].
class TableAdvancedController<T> extends ChangeNotifier {
  /// List of items to use to populate rows.
  ///
  /// You can either pass all the items of the table included in pagination or
  /// only the items to show in the initial page.
  /// The other content can then be loaded depending on shown page using the
  /// `onChangePage` callback of this controller.
  final List<T>? items;

  /// The method fired when the page shown by the table changes.
  ///
  /// This is an async method eventually returning a list of items. This can be useful
  /// for example to load new data with an API call depending on the current page,
  /// and then show the retrieved items in the table.
  final Future<List<T>?> Function(int page, int pageSize)? onChangePage;

  /// The method fired when row checkboxes are flagged/unflagged. Note that
  /// the entire list of flagged items is returned everytime a row is checked.
  final void Function(List<T> items)? onCheckItems;

  /// The table mode tu use.
  ///
  /// [TableMode.plain] will have no pagination management,
  /// [TableMode.paginationPage] will have pagination managed through navigation controls,
  /// [TableMode.paginationScroll] will have pagination managed through scolling
  final TableMode mode;

  /// Controller to manage content and properties of [TableAdvanced].
  ///
  /// Use the controller to set items to display in the table and eventually
  /// manage pagination and row checkboxes. You can use the `onChangePage`
  /// callback to load new data when the user changes table page or scolls to the bottom
  /// and then show the retrived items.
  ///
  /// If the total number of items expected in the table is different from the
  /// `items` list lenght (i.e. in case of paginated API calls), you can specify
  /// `rowsCountToPagination` to manage pagination consequently. If not provided,
  /// the number of items to manage the pagination will be taken by the `items` list.
  TableAdvancedController({
    this.items,
    int? rowsCountToPaginate,
    this.mode = TableMode.paginationScroll,
    this.onCheckItems,
    this.onChangePage,
    this.rowsToShow = 10,
  })  : assert(items != null || onChangePage != null),
        assert(items == null || mode != TableMode.plain) {
    this.rowsCountToPaginate = rowsCountToPaginate ?? items?.length ?? 0;

    if (mode == TableMode.plain) {
      rowsToShow = this.rowsCountToPaginate;
    }

    pageCount = _evaluatePageCount(
        rowsToShow: rowsToShow, rowsCount: this.rowsCountToPaginate);
    setItems(items ?? []);

    if (mode != TableMode.plain) {
      goToPage(1);
    }
  }

  /// The total number of items to use in the table pagination.
  late int rowsCountToPaginate;

  /// Number of rows to show in a page of the table. Defaults to 10.
  ///
  /// This is used if `mode` is [TableMode.paginationPage]
  int rowsToShow;

  /// The page currently shown in the table. Defaults to 1.
  int currentPage = 1;

  /// The number of pages of the table for pagination.
  late int pageCount;

  /// The entire list of items populating the table (independent of pagination)
  late List<T> dataItems;

  /// The list of items shown in the table for the current page and configuration
  late List<T> dataItemsToShow;

  /// The list of checked items.
  final List<T> checkedItems = [];

  bool _needToLoadMoreData() {
    return pageCount > currentPage;
  }

  int _evaluatePageCount({required int rowsToShow, required int rowsCount}) {
    var pages = rowsCount ~/ rowsToShow;
    if (rowsCount % rowsToShow != 0) {
      pages++;
    }
    return pages;
  }

  ScrollController? initScrollController() {
    if (mode != TableMode.paginationScroll) {
      return null;
    }

    ScrollController controller = ScrollController();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent &&
          _needToLoadMoreData()) {
        goToNextPage();
      }
    });
    // Verify if controller can be scrolled
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if ((controller.hasClients) && (controller.position.haveDimensions)) {
          if (controller.position.maxScrollExtent == 0) {
            if (_needToLoadMoreData()) {
              goToNextPage();
            }
          }
        }
      },
    );
    return controller;
  }

  /// Check or uncheck the specified items.
  ///
  /// Items already checked will be unchecked, and viceversa.
  ///
  /// If `checkAll` is _true_, if all items are checked every item will be unselected,
  /// otherwise all the items will result as selected independently of their checked status.
  void checkItems(
    List<T> items, {
    bool checkAll = false,
  }) {
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

  /// Change the number of rows to show per page
  void setRowsCount(int count) {
    rowsCountToPaginate = count;
    pageCount = _evaluatePageCount(
        rowsToShow: rowsToShow, rowsCount: rowsCountToPaginate);
    notifyListeners();
  }

  /// Reloads data for current page
  void reloadCurrentPage() {
    goToPage(currentPage);
  }

  /// Goes to the next page of the table
  ///
  /// This method will await the `onChangePage` callback, if provided. Furthermore,
  /// if the callback returns a new [List] of items, those will be shown, otherwise
  /// the initial items paged will be shown.
  void goToNextPage() {
    goToPage(currentPage + 1);
  }

  /// Goes to the previous page of the table
  ///
  /// This method will await the `onChangePage` callback, if provided. Furthermore,
  /// if the callback returns a new [List] of items, those will be shown, otherwise
  /// the initial items paged will be shown.
  void goToPreviousPage() {
    goToPage(currentPage - 1);
  }

  /// Goes to the specified page
  ///
  /// This method will await the `onChangePage` callback, if provided. Furthermore,
  /// if the callback returns a new [List] of items, those will be shown, otherwise
  /// the initial items paged will be shown.
  void goToPage(int page, {bool pageStartsFromZero = false}) async {
    currentPage = page + (pageStartsFromZero ? 1 : 0);
    var newItems = await onChangePage?.call(currentPage, rowsToShow);
    setItems(newItems ?? dataItems, replace: newItems != null, reload: true);
  }

  /// Changed the number of rows to show per page
  void changeNumberOfRowsToShow(int number) async {
    currentPage = 1;
    rowsToShow = number;
    pageCount = _evaluatePageCount(
        rowsToShow: rowsToShow, rowsCount: rowsCountToPaginate);
    var newData = await onChangePage?.call(currentPage, rowsToShow);
    setItems(newData ?? dataItems,
        replace: newData != null && mode != TableMode.paginationScroll,
        reload: true);
  }

  /// Set items to populate the table.
  ///
  /// If `replace` is _true_, all the items populating the table will be replaced, otherwise
  /// new items will be appended. Note that this is required to manage two different logics:
  /// - If you want a table with single visbile pages to be scrolled throug navigation controls,
  /// you should replace the items every time the user changes page.
  /// - If you want a table with a scrolling pagination (i.e. the user arrives to the bottom
  /// of the table and new data loads), new items should be appendend to the initial ones.
  void setItems(List<T> items, {bool replace = false, bool reload = false}) {
    if (replace) {
      this.dataItems.addAll(List.of(items));
    } else {
      this.dataItems = List.of(items);
    }
    dataItemsToShow = _evaluateRowsToShow(replace: replace);

    if (reload) {
      notifyListeners();
    }
  }

  List<T> _evaluateRowsToShow({bool replace = false}) {
    if (replace) {
      return List.of(dataItems);
    }

    List<T> rows = [];

    if (mode == TableMode.paginationScroll) {
      rows = List.of(dataItems);
      rowsToShow = rowsToShow ~/ currentPage + rowsToShow;
    } else {
      var initialIndexToSplit = (currentPage - 1) * rowsToShow;
      if (dataItems.length < initialIndexToSplit) {
        return [];
      }

      rows = List.of(dataItems.sublist(initialIndexToSplit));
    }

    if (rowsToShow < rows.length) {
      rows = List.of(rows.sublist(0, rowsToShow));
    }
    return rows;
  }
}
