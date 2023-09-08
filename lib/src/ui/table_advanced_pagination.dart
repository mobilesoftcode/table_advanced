import 'dart:math';

import 'package:table_advanced/table_advanced.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TableAdvancedPagination<T> extends StatefulWidget {
  final TableAdvancedController<T> controller;
  const TableAdvancedPagination({super.key, required this.controller});

  @override
  State<TableAdvancedPagination<T>> createState() =>
      _TableAdvancedPaginationState<T>();
}

class _TableAdvancedPaginationState<T>
    extends State<TableAdvancedPagination<T>> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _pageControls(),
        _rowNumberControl(),
      ],
    );
  }

  Widget _pageControls() {
    var pages = context.watch<TableAdvancedController<T>>().pageCount;
    var currentPage = context.read<TableAdvancedController<T>>().currentPage;
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 48,
            color: currentPage == 1 ? Colors.grey : Colors.black,
          ),
          onPressed: currentPage == 1
              ? null
              : () {
                  context.read<TableAdvancedController<T>>().goToPreviousPage();
                },
        ),
        const SizedBox(
          width: 4,
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(100)),
          child: Builder(builder: (context) {
            var pageButtonsToShow = min(7, pages);

            return Row(
              children: List.generate(
                pageButtonsToShow,
                (index) {
                  if (pages <= pageButtonsToShow) {
                    return _pageNumberButton(index + 1,
                        isSelected: currentPage == index + 1);
                  }

                  if (index == 0) {
                    return _pageNumberButton(1, isSelected: currentPage == 1);
                  }

                  if (index == pageButtonsToShow - 1) {
                    return _pageNumberButton(pages,
                        isSelected: currentPage == pages);
                  }

                  if (currentPage > 4) {
                    if (index == 1) {
                      return _pageNumberButton(null);
                    }

                    if (currentPage < pages - 3) {
                      switch (index) {
                        case 2:
                          return _pageNumberButton(currentPage - 1);
                        case 3:
                          return _pageNumberButton(currentPage,
                              isSelected: true);
                        case 4:
                          return _pageNumberButton(currentPage + 1);
                        default:
                      }
                    }
                  }

                  if (currentPage >= pages - 3) {
                    var newIndex = pages - (pageButtonsToShow - index - 1);
                    return _pageNumberButton(newIndex,
                        isSelected: currentPage == newIndex);
                  } else {
                    if (index == pageButtonsToShow - 2) {
                      return _pageNumberButton(null);
                    }
                  }

                  return _pageNumberButton(index + 1,
                      isSelected: currentPage == index + 1);
                },
              ),
            );
          }),
        ),
        const SizedBox(
          width: 4,
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            size: 48,
            color: currentPage == pages ? Colors.grey : Colors.black,
          ),
          onPressed: currentPage == pages
              ? null
              : () {
                  context.read<TableAdvancedController<T>>().goToNextPage();
                },
        ),
      ],
    );
  }

  Widget _pageNumberButton(int? page, {bool isSelected = false}) {
    return InkWell(
      onTap: page != null
          ? () {
              context.read<TableAdvancedController<T>>().goToPage(page);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 32,
        decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.grey,
            borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Text(
            page != null ? page.toString() : "...",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.black,
                ),
          ),
        ),
      ),
    );
  }

  Widget _rowNumberControl() {
    var rowsCount =
        context.read<TableAdvancedController<T>>().rowsCountToPaginate;
    var rowsToShow = context.read<TableAdvancedController<T>>().rowsToShow;
    return Row(
      children: [
        Text("Totali $rowsCount"),
        const SizedBox(
          width: 8,
        ),
        SizedBox(
          width: 200,
          child: DropdownButton<int>(
            value: rowsToShow,
            items: List.generate(
              4,
              (index) => DropdownMenuItem(
                value: (index + 1) * 5,
                child: Text(
                  ((index + 1) * 5).toString(),
                ),
              ),
            ),
            selectedItemBuilder: (context) {
              return List.generate(
                4,
                (index) => DropdownMenuItem(
                  child: Text(
                    "Mostrati ${(index + 1) * 5}",
                  ),
                ),
              );
            },
            onChanged: (value) {
              if (value == null) {
                return;
              }
              context
                  .read<TableAdvancedController<T>>()
                  .changeNumberOfRowsToShow(value);
            },
          ),
        ),
      ],
    );
  }
}
