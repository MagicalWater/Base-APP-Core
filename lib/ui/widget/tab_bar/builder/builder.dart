import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

export 'text_tab_builder.dart';
export 'widget_tab_builder.dart';

abstract class _BaseBuilder {
  int get tabCount;

  int get actionCount;
}

abstract class TabBuilder implements _BaseBuilder {
  Widget buildTab({
    BuildContext context,
    bool isSelected,
    int index,
    VoidCallback onTap,
  });

  Widget buildAction({
    BuildContext context,
    int index,
    VoidCallback onTap,
  });
}

abstract class SwipeTabBuilder implements _BaseBuilder {
  TabStyleBuilder<Decoration> get swipeDecoration;
  EdgeInsetsGeometry get padding;
  EdgeInsetsGeometry get margin;

  Widget buildTabBackground({
    BuildContext context,
    bool selected,
    int index,
  });

  Widget buildTabForeground({
    BuildContext context,
    Size size,
    bool selected,
    int index,
    VoidCallback onTap,
  });

  Widget buildActionBackground({
    BuildContext context,
    int index,
  });

  Widget buildActionForeground({
    BuildContext context,
    Size size,
    int index,
    VoidCallback onTap,
  });
}
