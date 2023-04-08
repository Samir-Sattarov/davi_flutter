import 'package:davi/src/column_width_behavior.dart';
import 'package:davi/src/internal/row_callbacks.dart';
import 'package:davi/src/internal/scroll_controllers.dart';
import 'package:davi/src/internal/scroll_offsets.dart';
import 'package:davi/src/internal/table_layout.dart';
import 'package:davi/src/internal/table_layout_child.dart';
import 'package:davi/src/internal/table_layout_settings.dart';
import 'package:davi/src/internal/table_scrollbar.dart';
import 'package:davi/src/internal/theme_metrics/theme_metrics.dart';
import 'package:davi/src/last_row_widget_listener.dart';
import 'package:davi/src/last_visible_row_listener.dart';
import 'package:davi/src/model.dart';
import 'package:davi/src/row_color.dart';
import 'package:davi/src/row_cursor.dart';
import 'package:davi/src/row_hover_listener.dart';
import 'package:davi/src/theme/theme.dart';
import 'package:davi/src/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@internal
class TableLayoutBuilder<DATA> extends StatelessWidget {
  const TableLayoutBuilder(
      {Key? key,
      required this.onHover,
      required this.scrollControllers,
      required this.onLastVisibleRow,
      required this.model,
      required this.themeMetrics,
      required this.columnWidthBehavior,
      required this.visibleRowsLength,
      required this.rowCallbacks,
      required this.onDragScroll,
        required this.jsonSizes,

        required this.scrolling,
        required this.onSizeChanged,

        required this.lastRowWidget,
      required this.onLastRowWidget,
      required this.rowColor,
      required this.rowCursor,
      required this.tapToSortEnabled})
      : super(key: key);

  final OnLastVisibleRowListener onLastVisibleRow;
  final OnRowHoverListener? onHover;
  final ScrollControllers scrollControllers;
  final DaviModel<DATA>? model;
  final Map<int, double> jsonSizes;

  final ColumnWidthBehavior columnWidthBehavior;
  final Function(double,  int) onSizeChanged;

  final int? visibleRowsLength;
  final OnDragScroll onDragScroll;
  final bool scrolling;
  final RowCallbacks<DATA> rowCallbacks;
  final TableThemeMetrics themeMetrics;
  final Widget? lastRowWidget;
  final OnLastRowWidgetListener onLastRowWidget;
  final DaviRowColor<DATA>? rowColor;
  final DaviRowCursor<DATA>? rowCursor;
  final bool tapToSortEnabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _builder);
  }

  Widget _builder(BuildContext context, BoxConstraints constraints) {
    final DaviThemeData theme = DaviTheme.of(context);

    final HorizontalScrollOffsets horizontalScrollOffsets =
        HorizontalScrollOffsets(scrollControllers);

    TableLayoutSettings layoutSettings = TableLayoutSettings(
        constraints: constraints,
        model: model,
        theme: theme,
        columnWidthBehavior: columnWidthBehavior,
        themeMetrics: themeMetrics,
        visibleRowsLength: visibleRowsLength,
        hasLastRowWidget: lastRowWidget != null);

    final List<TableLayoutChild> children = [];

    if (layoutSettings.hasVerticalScrollbar) {
      children.add(TableLayoutChild.verticalScrollbar(
          child: TableScrollbar(
              axis: Axis.vertical,
              contentSize: layoutSettings.contentHeight,
              scrollController: scrollControllers.vertical,
              color: theme.scrollbar.verticalColor,
              borderColor: theme.scrollbar.verticalBorderColor,
              onDragScroll: onDragScroll)));
    }

    if (themeMetrics.header.visible) {
      children.add(TableLayoutChild.header(
          layoutSettings: layoutSettings,
          model: model,
          jsonSizes: jsonSizes,
          resizable: columnWidthBehavior == ColumnWidthBehavior.scrollable,
          tapToSortEnabled: tapToSortEnabled,
          onSizeChanged: onSizeChanged,

          horizontalScrollOffsets: horizontalScrollOffsets));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild.topCorner());
      }
    }

    if (layoutSettings.hasHorizontalScrollbar) {
      Widget leftPinnedHorizontalScrollbar = TableScrollbar(
          axis: Axis.horizontal,
          scrollController: scrollControllers.leftPinnedHorizontal,
          color: theme.scrollbar.pinnedHorizontalColor,
          borderColor: theme.scrollbar.pinnedHorizontalBorderColor,
          contentSize: layoutSettings.leftPinnedContentWidth,
          onDragScroll: onDragScroll);
      children.add(TableLayoutChild.leftPinnedHorizontalScrollbar(
          leftPinnedHorizontalScrollbar));
      children.add(TableLayoutChild.unpinnedHorizontalScrollbar(TableScrollbar(
          axis: Axis.horizontal,
          scrollController: scrollControllers.unpinnedHorizontal,
          color: theme.scrollbar.unpinnedHorizontalColor,
          borderColor: theme.scrollbar.unpinnedHorizontalBorderColor,
          contentSize: layoutSettings.unpinnedContentWidth,
          onDragScroll: onDragScroll)));
      if (layoutSettings.hasVerticalScrollbar) {
        children.add(TableLayoutChild.bottomCorner());
      }
    }

    children.add(TableLayoutChild<DATA>.rows(
        model: model,
        layoutSettings: layoutSettings,
        scrolling: scrolling,
        horizontalScrollOffsets: horizontalScrollOffsets,
        verticalScrollController: scrollControllers.vertical,
        onHover: onHover,
        rowCallbacks: rowCallbacks,
        rowColor: rowColor,
        rowCursor: rowCursor,
        lastRowWidget: lastRowWidget,
        onLastVisibleRow: onLastVisibleRow,
        onLastRowWidget: onLastRowWidget));

    return TableLayout<DATA>(
        layoutSettings: layoutSettings,
        theme: theme,
        horizontalScrollOffsets: horizontalScrollOffsets,
        children: children);
  }
}
