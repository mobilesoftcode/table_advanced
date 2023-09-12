This package contains a table for Flutter projects.
<br>
The table can be shown either in plain mode or with pagination. Furthermore pagination can be managed on scroll or with navigation controls. The table has responsive behaviour on smaller screens, enabling to scoll either vertically or horizontally. Rows are build with a ListView builder, meaning that there are no performance issues for large amount of data.

## Usage
The table requires a controller to set items and eventually manage pagination. Widget builders are used to build column headers and rows.

To initialize the table in plain mode, namely without pagination and with all the items already shown, initialize the widget as follows

``` dart
return TableAdvanced<String>(
    columnHeaders: [
        TableAdvancedColumnHeader(
        child: const Text("Property 1"),
        ),
        TableAdvancedColumnHeader(
        child: const Text("Property 2"),
        ),
    ],
    rowBuilder: (item) {
        return TableAdvancedRow(
            data: DataRow(cells: [
                DataCell(
                    Text(item),
                ),
                DataCell(
                    Container(color: Colors.red, child: const Text("Test value"))
                ),
            ],
            ),
        );
    },
    controller: TableAdvancedController(
        items: List.generate(99, (index) => index.toString()),
        mode: TableMode.plain,
    ),
);
```

For specific properties regarding column headers and rows, check their class documentation.

If you want to enable checkboxes for table rows, pass the `onCheckItems` argument to `TableAdvancedController`. You can also use the controller's `onChangePage` callback to load new data when the user changes table page or scolls to the bottom and then show the retrived items.

If you set the `TableMode.paginationPage` mode, pagination will be managed through navigation controls, and table content will be replaced at every page change. Using `TableMode.paginationScroll` instead, shows new content when the user scrolls to the bottom of the table, appending new items at the end of the list.

The controller can be used to programmatically change page (`goToPage`) or change table items (`setItems`), either adding them to the table or replacing items completely.

Remind to dispose the controller when needed.
## Additional information

This package is mantained by the Competence Center Flutter of Mobilesoft Srl.
