import 'package:table_advanced/table_advanced.dart';
import '../table_advanced_controller.dart';
import 'table_advanced_pagination.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';

class AdvancedTableColumnHeader {
  final Widget child;
  final int flex;
  final VoidCallback? onTap;

  AdvancedTableColumnHeader({
    required this.child,
    this.flex = 1,
    this.onTap,
  });
}

class AdvancedTableRow {
  final DataRow data;
  final BoxDecoration Function(BuildContext context, int index)? style;
  final bool? checked;
  final bool? disabled;
  final Widget? expandedWidget;
  final List<Widget>? actions;
  AdvancedTableRow({
    required this.data,
    this.style,
    this.checked,
    this.disabled,
    this.expandedWidget,
    this.actions,
  });
}

class TableAdvanced<T> extends StatefulWidget {
  final List<AdvancedTableColumnHeader> columnHeaders;
  final AdvancedTableRow Function(T item) rowBuilder;
  final TableAdvancedController<T> controller;
  final double rowSpacing;

  const TableAdvanced({
    Key? key,
    required this.columnHeaders,
    required this.rowBuilder,
    required this.controller,
    this.rowSpacing = 12,
  }) : super(key: key);

  @override
  createState() => _TableAdvancedState<T>();
}

class _TableAdvancedState<T> extends State<TableAdvanced<T>> {
  final LinkedScrollControllerGroup _tableControllers =
      LinkedScrollControllerGroup();

  late ScrollController _headerController;
  late ScrollController _bodyController;

  @override
  void initState() {
    super.initState();
    _headerController = _tableControllers.addAndGet();
    _bodyController = _tableControllers.addAndGet();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  bool _shouldShowScrollBar({required double width}) {
    //TODO
    if (kIsWeb &&
        (width < 700 || (width < 1200 && widget.columnHeaders.length > 8))) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Builder(
        builder: (context) {
          if (widget.controller.dataItemsToShow.isEmpty) {
            return const SizedBox.shrink();
          }

          var showScrollBar =
              _shouldShowScrollBar(width: MediaQuery.of(context).size.width);
          return showScrollBar
              ? Scrollbar(
                  thumbVisibility: true,
                  controller: _headerController,
                  child: _table(showScrollBar: showScrollBar),
                )
              : _table(showScrollBar: showScrollBar);
        },
      ),
    );
  }

  Widget _table({required bool showScrollBar}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _shouldShowScrollBar(width: constraints.maxWidth)
                  ? SingleChildScrollView(
                      controller: _headerController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: 800, child: _tableHeader()))
                  : _tableHeader(),
              SizedBox(
                height: widget.rowSpacing,
              ),
              Flexible(
                child: _shouldShowScrollBar(width: constraints.maxWidth)
                    ? SingleChildScrollView(
                        controller: _bodyController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(width: 800, child: _tableRows()))
                    : _tableRows(),
              ),
              TableAdvancedPagination(controller: widget.controller),
            ],
          ),
        );
      },
    );
  }

  Widget _tableHeader() {
    return Builder(builder: (context) {
      return Row(
        children: [
          if (widget.controller.onCheckItems != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Checkbox(
                value: context
                        .watch<TableAdvancedController<T>>()
                        .checkedItems
                        .length ==
                    widget.controller.dataItemsToShow.length,
                onChanged: (checked) {
                  widget.controller.checkItems(
                      widget.controller.dataItemsToShow,
                      checkAll: true,
                      checked: checked ?? false);
                },
              ),
            ),
          Expanded(
            child: Row(
              children: [
                ...List.generate(
                  widget.columnHeaders.length,
                  (index) => Expanded(
                    flex: widget.columnHeaders[index].flex,
                    child: Material(
                      child: InkWell(
                        onTap: widget.columnHeaders[index].onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: widget.columnHeaders[index].child,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _tableRows() {
    return Builder(builder: (context) {
      var dataRows =
          context.watch<TableAdvancedController<T>>().dataItemsToShow;

      return ListView.separated(
        itemCount: dataRows.length,
        separatorBuilder: (context, index) => SizedBox(
          height: widget.rowSpacing,
        ),
        // shrinkWrap: !Sizes.isScreenSizeMedium(context),
        itemBuilder: (context, index) {
          var item = widget.rowBuilder(dataRows[index]);
          bool isOpen = false;
          List<Widget> children = [];
          for (var cell in item.data.cells) {
            children.add(Expanded(
                flex: widget.columnHeaders[item.data.cells.indexOf(cell)].flex,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: cell.child,
                )));
          }

          return StatefulBuilder(builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: item.data.onSelectChanged != null
                      ? () => item.data.onSelectChanged!(true)
                      : null,
                  child: Container(
                    decoration: item.style?.call(context, index),
                    child: Row(
                      children: [
                        if (widget.controller.onCheckItems != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Checkbox(
                              value: item.checked ??
                                  context
                                      .watch<TableAdvancedController<T>>()
                                      .checkedItems
                                      .contains(dataRows[index]),
                              onChanged: (item.disabled ?? false)
                                  ? null
                                  : (checked) {
                                      widget.controller.checkItems([
                                        dataRows[index],
                                      ], checked: checked ?? false);
                                    },
                            ),
                          ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Row(
                                children: children,
                              ),
                              Row(
                                children: [
                                  const Spacer(),
                                  for (var action in item.actions ?? <Widget>[])
                                    SizedBox(
                                      width: 40,
                                      child: action,
                                    ),
                                  if (item.expandedWidget != null)
                                    SizedBox(
                                      width: 40,
                                      child: IconButton(
                                        icon: Icon(isOpen
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down),
                                        onPressed: () {
                                          setState(() {
                                            isOpen = !isOpen;
                                          });
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isOpen) item.expandedWidget ?? const SizedBox.shrink(),
              ],
            );
          });
        },
      );
    });
  }
}
