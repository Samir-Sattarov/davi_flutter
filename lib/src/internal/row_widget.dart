import 'package:easy_table/src/cell_icon.dart';
import 'package:easy_table/src/cell_style.dart';
import 'package:easy_table/src/column.dart';
import 'package:easy_table/src/internal/columns_layout_child.dart';
import 'package:easy_table/src/internal/columns_layout.dart';
import 'package:easy_table/src/internal/row_callbacks.dart';
import 'package:easy_table/src/internal/column_metrics.dart';
import 'package:easy_table/src/internal/table_layout_settings.dart';
import 'package:easy_table/src/theme/theme.dart';
import 'package:easy_table/src/theme/theme_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class RowWidget<ROW> extends StatefulWidget {
  RowWidget(
      {required this.rowIndex,
      required this.row,
      required this.layoutSettings,
      required this.scrolling,
      required this.rowCallbacks})
      : super(key: ValueKey<int>(rowIndex));

  final ROW row;
  final int rowIndex;
  final bool scrolling;
  final TableLayoutSettings<ROW> layoutSettings;
  final RowCallbacks<ROW> rowCallbacks;

  @override
  State<StatefulWidget> createState() => RowWidgetState<ROW>();
}

class RowWidgetState<ROW> extends State<RowWidget<ROW>> {
  bool _enter = false;
  @override
  Widget build(BuildContext context) {
    EasyTableThemeData theme = EasyTableTheme.of(context);

    List<ColumnsLayoutChild<ROW>> children = [];

    for (int columnIndex = 0;
        columnIndex < widget.layoutSettings.columnsMetrics.length;
        columnIndex++) {
      final ColumnMetrics<ROW> columnMetrics =
          widget.layoutSettings.columnsMetrics[columnIndex];
      final EasyTableColumn<ROW> column = columnMetrics.column;
      final Widget cell = _buildCellWidget(
          context: context,
          row: widget.row,
          rowIndex: widget.rowIndex,
          column: column,
          theme: theme);
      children.add(ColumnsLayoutChild<ROW>(index: columnIndex, child: cell));
    }

    Widget layout = ColumnsLayout(
        layoutSettings: widget.layoutSettings, children: children);

    if (widget.rowCallbacks.hasCallback) {
      layout = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _buildOnTap(),
          onDoubleTap: _buildOnDoubleTap(),
          onSecondaryTap: _buildOnSecondaryTap(),
          child: layout);
    }

    if (widget.rowCallbacks.hasCallback || theme.row.hoveredColor != null) {
      Color? color = _enter && !widget.scrolling ? Colors.blue[300] : null;
      if (theme.row.hoveredColor != null) {
        color = _enter && !widget.scrolling
            ? theme.row.hoveredColor!(widget.rowIndex)
            : null;
      }
      layout = MouseRegion(
          onEnter: widget.scrolling ? null : _onEnter,
          cursor:
              widget.scrolling ? MouseCursor.defer : SystemMouseCursors.click,
          onExit: widget.scrolling ? null : _onExit,
          child: Container(color: color, child: layout));
    }

    return layout;
  }

  Widget _buildCellWidget(
      {required BuildContext context,
      required ROW row,
      required int rowIndex,
      required EasyTableColumn<ROW> column,
      required EasyTableThemeData theme}) {
    // Theme
    EdgeInsets? padding = theme.cell.padding;
    Alignment? alignment = theme.cell.alignment;
    TextStyle? textStyle = theme.cell.textStyle;
    TextOverflow? overflow = theme.cell.overflow;
    // Entire column
    padding = column.cellPadding ?? padding;
    alignment = column.cellAlignment ?? alignment;
    Color? background = column.cellBackground;
    textStyle = column.cellTextStyle ?? textStyle;
    overflow = column.cellOverflow ?? overflow;
    // Single cell
    if (column.cellStyleBuilder != null) {
      CellStyle? cellStyle = column.cellStyleBuilder!(row);
      if (cellStyle != null) {
        padding = cellStyle.padding ?? padding;
        alignment = cellStyle.alignment ?? alignment;
        background = cellStyle.background ?? background;
        textStyle = cellStyle.textStyle ?? textStyle;
        overflow = cellStyle.overflow ?? overflow;
      }
    }

    Widget? child;
    if (column.cellBuilder != null) {
      child = column.cellBuilder!(context, row, rowIndex);
    } else if (column.iconValueMapper != null) {
      CellIcon? cellIcon = column.iconValueMapper!(row);
      if (cellIcon != null) {
        child = Icon(cellIcon.icon, color: cellIcon.color, size: cellIcon.size);
      }
    } else {
      String? value = _stringValue(column: column, row: row);
      if (value != null) {
        child = Text(value,
            overflow: overflow ?? theme.cell.overflow,
            style: textStyle ?? theme.cell.textStyle);
      } else if (theme.cell.nullValueColor != null) {
        background = theme.cell.nullValueColor!(rowIndex);
      }
    }
    if (child != null) {
      child = Align(child: child, alignment: alignment);
      if (padding != null) {
        child = Padding(padding: padding, child: child);
      }
    }
    if (background != null) {
      child = Container(child: child, color: background);
    }
    return ClipRect(child: child);
  }

  GestureTapCallback? _buildOnTap() {
    if (widget.rowCallbacks.onRowTap != null) {
      return () => widget.rowCallbacks.onRowTap!(widget.row);
    }
    return null;
  }

  GestureTapCallback? _buildOnDoubleTap() {
    if (widget.rowCallbacks.onRowDoubleTap != null) {
      return () => widget.rowCallbacks.onRowDoubleTap!(widget.row);
    }
    return null;
  }

  GestureTapCallback? _buildOnSecondaryTap() {
    if (widget.rowCallbacks.onRowSecondaryTap != null) {
      return () => widget.rowCallbacks.onRowSecondaryTap!(widget.row);
    }
    return null;
  }

  String? _stringValue(
      {required EasyTableColumn<ROW> column, required ROW row}) {
    if (column.stringValueMapper != null) {
      return column.stringValueMapper!(row);
    } else if (column.intValueMapper != null) {
      return column.intValueMapper!(row)?.toString();
    } else if (column.doubleValueMapper != null) {
      final double? doubleValue = column.doubleValueMapper!(row);
      if (doubleValue != null) {
        if (column.fractionDigits != null) {
          return doubleValue.toStringAsFixed(column.fractionDigits!);
        } else {
          return doubleValue.toString();
        }
      }
    } else if (column.objectValueMapper != null) {
      return column.objectValueMapper!(row)?.toString();
    }
    return null;
  }

  void _onEnter(PointerEnterEvent event) {
    setState(() => _enter = true);
  }

  void _onExit(PointerExitEvent event) {
    setState(() => _enter = false);
  }
}
