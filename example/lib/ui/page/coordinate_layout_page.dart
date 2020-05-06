import 'dart:math';

import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';

import '../../router/route.dart';
import 'introduction_page.dart';

/// 展示座標佈局元件
@ARoute(url: Pages.coordinateLayout)
class CoordinateLayoutPage extends StatefulWidget {

  final RouteOption option;

  CoordinateLayoutPage(this.option): super();

  @override
  _CoordinateLayoutPageState createState() => _CoordinateLayoutPageState();
}

class _CoordinateLayoutPageState extends State<CoordinateLayoutPage> {
  var title = "座標佈局";
  var content = """
  座標佈局
  1. 可自訂 x, y 位置
  2. 可設置 x, y 的 span(佔用寬度/高度數量)
  """;

  var style = TextStyle(
    color: Colors.white,
  );

  Color get randomColor {
    return Color.fromARGB(
      255,
      Random().nextInt(100) + 30,
      Random().nextInt(100) + 30,
      Random().nextInt(100) + 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      haveAppBar: true,
      title: title,
      child: SafeArea(
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.all(4),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildIntroduction(content),
                CoordinateLayout(
                  segmentCount: 4,
                  horizontalSpace: 4,
                  verticalSpace: 4,
                  estimatedHeight: 1000,
                  children: [
                    buildAxisItem(x: 0, y: 0, ySpan: 3),
                    buildAxisItem(x: 1, y: 0, xSpan: 3),
                    buildAxisItem(x: 3, y: 1, ySpan: 3),
                    buildAxisItem(x: 0, y: 3, xSpan: 3),
                    buildAxisItem(x: 1, y: 1, xSpan: 2, ySpan: 2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAxisItem({int x, int y, int xSpan = 1, int ySpan = 1}) {
    var item;
    item = AxisItem(
      x: x,
      y: y,
      xSpan: xSpan,
      ySpan: ySpan,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: randomColor,
        ),
        height: 100,
        child: Builder(
          builder: (_) => Text(
            item.toString(),
            style: style,
          ),
        ),
      ),
    );
    return item;
  }
}
