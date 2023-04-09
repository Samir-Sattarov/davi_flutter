import 'package:davi/src/column.dart';
import 'package:davi/src/internal/columns_layout.dart';
import 'package:davi/src/internal/columns_layout_child.dart';
import 'package:davi/src/internal/header_cell.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/model.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class HeaderWidget<DATA> extends StatefulWidget {
  const HeaderWidget(
      {Key? key,
      required this.layoutSettings,
      required this.model,
      required this.resizable,
      required this.jsonSizes,
      required this.horizontalScrollOffsets,
      required this.onSizeChanged,
      required this.tapToSortEnabled})
      : super(key: key);

  final TableLayoutSettings layoutSettings;
  final DaviModel<DATA> model;
  final bool resizable;
  final Map<int, double> jsonSizes;
  final Function(double, int) onSizeChanged;

  final HorizontalScrollOffsets horizontalScrollOffsets;
  final bool tapToSortEnabled;

  @override
  State<HeaderWidget<DATA>> createState() => _HeaderWidgetState<DATA>();
}

class _HeaderWidgetState<DATA> extends State<HeaderWidget<DATA>> {
  @override
  Widget build(BuildContext context) {
    DaviThemeData theme = DaviTheme.of(context);

    List<ColumnsLayoutChild<DATA>> children = [];

    final isMultiSorted = widget.model.isMultiSorted;

    for (int columnIndex = 0;
        columnIndex < widget.model.columnsLength;
        columnIndex++) {
      final DaviColumn<DATA> column = widget.model.columnAt(columnIndex);

      final Widget cell = DaviHeaderCell<DATA>(
          key: ValueKey<int>(columnIndex),
          model: widget.model,
          column: column,
          jsonSizes: widget.jsonSizes,
          resizable: widget.resizable,
          tapToSortEnabled: widget.tapToSortEnabled,
          isMultiSorted: isMultiSorted,
          onSizeChanged: widget.onSizeChanged,
          columnIndex: columnIndex);
      children.add(ColumnsLayoutChild<DATA>(index: columnIndex, child: cell));
    }

    Widget header = ColumnsLayout(
        layoutSettings: widget.layoutSettings,
        horizontalScrollOffsets: widget.horizontalScrollOffsets,
        paintDividerColumns: true,
        children: children);

    Color? color = theme.header.color;
    BoxBorder? border;
    if (theme.header.bottomBorderHeight > 0 &&
        theme.header.bottomBorderColor != null) {
      border = Border(
          bottom: BorderSide(
              width: theme.header.bottomBorderHeight,
              color: theme.header.bottomBorderColor!));
    }

    if (color != null || border != null) {
      header = Container(
          decoration: BoxDecoration(border: border, color: color),
          child: header);
    }
    return header;
  }
}
