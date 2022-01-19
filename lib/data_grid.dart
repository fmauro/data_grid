library data_grid;

import 'dart:math';

import 'package:flutter/material.dart';

class DataGrid extends StatefulWidget {
  const DataGrid(
      {Key? key,
      required this.controller,
      this.onValueChanged,
      this.onFocusedRowChanged,
      this.onFocusedColumnChanged,
      this.minWidth = 0})
      : super(key: key);

  final DataGridController controller;

  final Function(int col, int row, dynamic value)? onValueChanged;
  final Function(int row)? onFocusedRowChanged;
  final Function(int col)? onFocusedColumnChanged;

  final double minWidth;

  @override
  State<DataGrid> createState() => _DataGridState();
}

class _DataGridState extends State<DataGrid> {
  int? _focusedRow;
  int? _focusedColumn;

  final Map<int, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() => setState(() {}));

    final columns = widget.controller.columns;
    final rows = widget.controller.rows;

    for (int c = 0; c < columns.length; c++) {
      for (int r = 0; r < rows.length; r++) {
        if (!columns[c].readOnly) {
          final focusNode = FocusNode();
          _focusNodes[c * rows.length + r] = focusNode;
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

  @override
  Widget build(BuildContext context) {
    final columns = widget.controller.columns;
    final rows = widget.controller.rows;

    return LayoutBuilder(builder: (context, constraints) {
      final double width = max(widget.minWidth, constraints.maxWidth);
      final cellWidth = width / columns.length;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: width),
          child: DataTable(
            horizontalMargin: 0,
            checkboxHorizontalMargin: 0,
            columnSpacing: 0,
            columns: columns.map((e) => DataColumn(label: e.label)).toList(),
            rows: [
              for (int r = 0; r < rows.length; r++)
                DataRow(cells: [
                  for (int c = 0; c < columns.length; c++)
                    _buildCell(c, r, cellWidth)
                ]),
            ],
          ),
        ),
      );
    });
  }

  DataCell _buildCell(int col, int row, double? cellWidth) {
    final columns = widget.controller.columns;
    final rows = widget.controller.rows;

    final column = columns[col];
    final cellValue = rows[row][col];
    final cellIndex = col * rows.length + row;

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
            focusNode: _focusNodes[cellIndex],
            decoration: decoration,
            controller: widget.controller.controllers[col * rows.length + row],
            readOnly: column.readOnly,
            onChanged: (value) => _setValue(col, row, value));
        break;
      case ColumnType.checkbox:
        child = Checkbox(
            focusNode: _focusNodes[cellIndex],
            value: cellValue,
            onChanged: column.readOnly
                ? null
                : (value) {
                    if (column.readOnly) return;
                    _setFocusedRow(row);
                    _setFocusedColumn(col);
                    _setValue(col, row, value);
                  });
        break;
      case ColumnType.widget:
        child = column.readOnly
            ? cellValue
            : Focus(
                focusNode: _focusNodes[cellIndex],
                child: cellValue,
              );
        break;
    }

    return DataCell(Container(
      width: cellWidth,
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

  void _setFocusedRow(int row) {
    if (_focusedRow != row) {
      setState(() {
        _focusedRow = row;
      });
      if (widget.onFocusedRowChanged != null) {
        widget.onFocusedRowChanged!(row);
      }
    }
  }

  void _setFocusedColumn(int col) {
    if (_focusedColumn != col) {
      setState(() {
        _focusedColumn = col;
      });

      if (widget.onFocusedColumnChanged != null) {
        widget.onFocusedColumnChanged!(col);
      }
    }
  }

  void _setValue(int col, int row, dynamic value) {
    if (value != widget.controller.rows[row][col]) {
      widget.controller.setCellValue(row, col, value, notify: false);
    }
    if (widget.onValueChanged != null) {
      widget.onValueChanged!(col, row, value);
    }
  }

  @override
  void dispose() {
    super.dispose();

    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
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

  GridColumn(
    this.label,
    this.type, {
    this.validator,
    this.hintText,
    this.readOnly = false,
    this.alignment = Alignment.center,
    this.textAlign = TextAlign.center,
  });
}

enum ColumnType { text, checkbox, widget }

class DataGridController extends ChangeNotifier {
  final List<GridColumn> columns;
  final List<List<dynamic>> rows;

  final Map<int, TextEditingController> controllers = {};

  DataGridController({
    required this.columns,
    required this.rows,
  }) {
    for (int c = 0; c < columns.length; c++) {
      for (int r = 0; r < rows.length; r++) {
        if (columns[c].type == ColumnType.text) {
          final controller = TextEditingController();
          controllers[c * rows.length + r] = controller;
          controller.text = rows[r][c];
        }
      }
    }
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

  @override
  void dispose() {
    super.dispose();

    for (var controller in controllers.values) {
      controller.dispose();
    }
  }
}
