library data_grid;

import 'dart:math';

import 'package:flutter/material.dart';

class DataGrid extends StatefulWidget {
  const DataGrid({Key? key, required this.controller, this.minWidth = 0})
      : super(key: key);

  final DataGridController controller;

  final double minWidth;

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  int? _sortColumn;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final columns = widget.controller.columns;
    final rows = widget.controller.rows;

    return LayoutBuilder(builder: (context, constraints) {
      final double width = max(widget.minWidth, constraints.maxWidth);
      final fullFlex = columns.map((c) => c.flex).reduce((a, b) => a + b);
      final singleFlexWidth = width / fullFlex;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: width, maxWidth: width),
          child: DataTable(
            sortAscending: _sortAscending,
            sortColumnIndex: _sortColumn,
            horizontalMargin: 0,
            checkboxHorizontalMargin: 0,
            columnSpacing: 0,
            columns: columns
                .map((e) => DataColumn(
                    onSort: e.onSort == null
                        ? null
                        : (columnIndex, ascending) {
                            setState(() {
                              _sortColumn = columnIndex;
                              _sortAscending = ascending;
                            });
                            rows.sort((one, two) => ascending
                                ? e.onSort!(one[columnIndex], two[columnIndex])
                                : e.onSort!(
                                    two[columnIndex], one[columnIndex]));

                            widget.controller.reloadData();
                          },
                    label: e.label))
                .toList(),
            rows: [
              for (int r = 0; r < rows.length; r++)
                DataRow(cells: [
                  for (int c = 0; c < columns.length; c++)
                    _buildCell(c, r, singleFlexWidth)
                ]),
            ],
          ),
        ),
      );
    });
  }

  DataCell _buildCell(int col, int row, double flexWidth) {
    final columns = widget.controller.columns;
    final rows = widget.controller.rows;

    final column = columns[col];
    final cellValue = rows[row][col];

    final decoration = InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding:
            const EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        hintText: columns[col].hintText);

    Widget? child;
    switch (columns[col].type) {
      case ColumnType.text:
        child = TextFormField(
            textAlign: column.textAlign,
            enabled: !column.readOnly,
            focusNode: widget.controller.focusNodes[Point(col, row)],
            decoration: decoration,
            controller: widget.controller.controllers[Point(col, row)],
            readOnly: column.readOnly,
            onChanged: (value) => _setValue(col, row, value));
        break;
      case ColumnType.checkbox:
        child = Checkbox(
            focusNode: widget.controller.focusNodes[Point(col, row)],
            value: cellValue,
            onChanged: column.readOnly
                ? null
                : (value) {
                    if (column.readOnly) return;
                    _setValue(col, row, value);
                  });
        break;
      case ColumnType.widget:
        child = column.readOnly
            ? cellValue
            : Focus(
                focusNode: widget.controller.focusNodes[Point(col, row)],
                child: cellValue,
              );
        break;
    }

    return DataCell(Container(
      width: column.flex * flexWidth,
      height: double.infinity,
      decoration: BoxDecoration(
          color: Colors.red.withAlpha(columns[col].validator != null &&
                  columns[col].validator!(col, row, cellValue) != null
              ? 50
              : 0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Align(
          child: child,
          alignment: column.alignment,
        ),
      ),
    ));
  }

  void _setValue(int col, int row, dynamic value) {
    if (value != widget.controller.rows[row][col]) {
      widget.controller.setCellValue(row, col, value);
    }
  }
}

class GridColumn {
  final Widget label;
  final ColumnType type;
  final bool readOnly;
  final String? Function(int col, int row, dynamic value)? validator;
  final String? hintText;
  final Alignment alignment;
  final TextAlign textAlign;
  final int flex;

  final int Function(dynamic one, dynamic two)? onSort;

  GridColumn(
    this.label,
    this.type, {
    this.validator,
    this.hintText,
    this.readOnly = false,
    this.alignment = Alignment.center,
    this.textAlign = TextAlign.center,
    this.flex = 1,
    this.onSort,
  });
}

enum ColumnType { text, checkbox, widget }

class DataGridController extends ChangeNotifier {
  final List<GridColumn> columns;
  final List<List<dynamic>> rows;

  int? _focusedRow;
  int? _focusedColumn;

  final Map<Point<int>, TextEditingController> controllers = {};
  final Map<Point<int>, FocusNode> focusNodes = {};

  DataGridController({
    required this.columns,
    required this.rows,
  }) {
    for (int c = 0; c < columns.length; c++) {
      for (int r = 0; r < rows.length; r++) {
        if (columns[c].type == ColumnType.text) {
          final controller = TextEditingController();
          controllers[Point(c, r)] = controller;
          controller.text = rows[r][c];
        }
        if (!columns[c].readOnly) {
          final focusNode = FocusNode();
          focusNodes[Point(c, r)] = focusNode;
          focusNode.addListener(() {
            if (focusNode.hasFocus) {
              _setFocusedColumn(c);
              _setFocusedRow(r);
            }
          });
        }
      }
    }
  }

  void _setFocusedRow(int row) {
    if (_focusedRow != row) {
      _focusedRow = row;
    }
  }

  void _setFocusedColumn(int col) {
    if (_focusedColumn != col) {
      _focusedColumn = col;
    }
  }

  reloadData() {
    for (int c = 0; c < columns.length; c++) {
      for (int r = 0; r < rows.length; r++) {
        if (columns[c].type == ColumnType.text) {
          controllers[Point(c, r)]?.text = rows[r][c];
        }
      }
    }

    notifyListeners();
  }

  setCellValue(int row, int col, dynamic value, {bool notify = true}) {
    rows[row][col] = value;
    if (notify) {
      controllers[col * rows.length + row]?.text = value;
      notifyListeners();
    }
  }

  dynamic getCellValue(int row, int col) {
    return rows[row][col];
  }

  addRow(List<dynamic> rowData) {
    rows.add(rowData);

    for (int c = 0; c < columns.length; c++) {
      if (columns[c].type == ColumnType.text) {
        final controller = TextEditingController();
        controllers[Point(c, rows.length - 1)] = controller;
        controller.text = rows[(rows.length - 1)][c];
      }
    }

    notifyListeners();
  }

  removeRow(int row) {
    rows.removeAt(row);

    reloadData();
  }

  @override
  void dispose() {
    super.dispose();

    for (var controller in controllers.values) {
      controller.dispose();
    }

    for (var focusNode in focusNodes.values) {
      focusNode.dispose();
    }
  }
}
