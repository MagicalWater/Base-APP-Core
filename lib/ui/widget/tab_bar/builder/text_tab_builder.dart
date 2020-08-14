import 'package:flutter/material.dart';
import 'package:mx_core/ui/widget/material_layer.dart';

import '../tab_style.dart';
import 'builder.dart';

class TextTabBuilder implements TabBuilder, SwipeTabBuilder {
  @override
  int get tabCount => texts.length;

  @override
  int get actionCount => actions?.length ?? 0;

  Decoration get swipeDecoration =>
      tabDecoration?.select ?? _defaultDecoration.select;

  BorderRadius getBorderRadius(Decoration decoration) {
    if (decoration is BoxDecoration) {
      return decoration.borderRadius;
    }
    return BorderRadius.zero;
  }

  final TabStyle<Decoration> tabDecoration;
  final TabStyle<TextStyle> tabTextStyle;
  final Decoration actionDecoration;
  final TextStyle actionTextStyle;
  final List<String> texts;
  final List<String> actions;
  final Duration duration;
  final Curve curve;
  final EdgeInsetsGeometry padding;

  TextTabBuilder({
    this.texts,
    this.padding,
    this.actions,
    this.tabDecoration,
    this.tabTextStyle,
    this.actionDecoration,
    this.actionTextStyle,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.fastOutSlowIn,
  });

  Decoration get _defaultActionDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey,
      border: Border.all(color: Colors.grey),
    );
  }

  TextStyle get _defaultActionTextStyle {
    return TextStyle(color: Colors.black, fontSize: 16);
  }

  TabStyle<Decoration> get _defaultDecoration {
    return TabStyle<Decoration>(
      select: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blueAccent,
        border: Border.all(color: Colors.blueAccent),
      ),
      unSelect: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
        border: Border.all(color: Colors.blueAccent),
      ),
    );
  }

  TabStyle<TextStyle> get _defaultTextStyle {
    return TabStyle<TextStyle>(
      select: TextStyle(color: Colors.white, fontSize: 16),
      unSelect: TextStyle(color: Colors.grey[400], fontSize: 16),
    );
  }

  @override
  Widget buildTab({bool isSelected, int index, VoidCallback onTap}) {
    var textStyle = isSelected
        ? (tabTextStyle?.select ?? _defaultTextStyle.select)
        : (tabTextStyle?.unSelect ?? _defaultTextStyle.unSelect);
    var decoration = isSelected
        ? (tabDecoration?.select ?? _defaultDecoration.select)
        : (tabDecoration?.unSelect ?? _defaultDecoration.unSelect);

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: getBorderRadius(decoration),
          onTap: onTap,
          child: Container(
            height: double.infinity,
            padding: padding,
            alignment: Alignment.center,
            child: AnimatedDefaultTextStyle(
              child: Text(texts[index]),
              style: textStyle,
              duration: duration,
              curve: curve,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildAction({int index, VoidCallback onTap}) {
    var decoration = actionDecoration ?? _defaultActionDecoration;
    var textStyle = actionTextStyle ?? _defaultActionTextStyle;
    return MaterialLayer.single(
      layer: LayerProperties(
        decoration: decoration,
      ),
      onTap: onTap,
      child: Container(
        height: double.infinity,
        padding: padding,
        alignment: Alignment.center,
        child: Text(actions[index], style: textStyle),
      ),
    );
  }

  @override
  Widget buildTabBackground({bool isSelected, int index}) {
    var textStyle = isSelected
        ? (tabTextStyle?.select ?? _defaultTextStyle.select)
        : (tabTextStyle?.unSelect ?? _defaultTextStyle.unSelect);
    var decoration = tabDecoration?.unSelect ?? _defaultDecoration.unSelect;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: decoration,
      height: double.infinity,
      padding: padding,
      child: AnimatedDefaultTextStyle(
        child: Text(texts[index]),
        style: textStyle.copyWith(color: Colors.transparent),
        duration: duration,
        curve: curve,
      ),
    );
  }

  @override
  Widget buildTabForeground(
      {Size size, bool isSelected, int index, VoidCallback onTap}) {
    var textStyle = isSelected
        ? (tabTextStyle?.select ?? _defaultTextStyle.select)
        : (tabTextStyle?.unSelect ?? _defaultTextStyle.unSelect);

    return MaterialLayer.single(
      layer: LayerProperties(
        width: size.width,
        height: size.height,
      ),
      onTap: onTap,
      child: Container(
        padding: padding,
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          child: Text(texts[index]),
          style: textStyle,
          duration: duration,
          curve: curve,
        ),
      ),
    );
  }

  @override
  Widget buildActionBackground({int index}) {
    var textStyle = actionTextStyle ?? _defaultActionTextStyle;
    var decoration = actionDecoration ?? _defaultActionDecoration;
    return Container(
      height: double.infinity,
      padding: padding,
      decoration: decoration,
      child: Text(
        actions[index],
        style: textStyle.copyWith(color: Colors.transparent),
      ),
    );
  }

  @override
  Widget buildActionForeground({Size size, int index, VoidCallback onTap}) {
    var textStyle = actionTextStyle ?? _defaultActionTextStyle;
    return MaterialLayer.single(
      layer: LayerProperties(
        width: size.width,
        height: size.height,
      ),
      onTap: onTap,
      child: Container(
        padding: padding,
        alignment: Alignment.center,
        child: Text(actions[index], style: textStyle),
      ),
    );
  }
}