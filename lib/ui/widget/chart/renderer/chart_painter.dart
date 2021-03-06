import 'dart:async' show StreamSink;

import 'package:flutter/material.dart';
import 'package:mx_core/util/num_util.dart';

import '../entity/info_window_entity.dart';
import '../entity/k_line_entity.dart';
import '../k_chart.dart';
import '../utils/date_format_util.dart';
import 'base_chart_painter.dart';
import 'base_chart_renderer.dart';
import 'main_renderer.dart';
import 'secondary_renderer.dart';
import 'vol_renderer.dart';

class ChartPainter extends BaseChartPainter {
  BaseChartRenderer mMainRenderer, mVolRenderer, mSecondaryRenderer;
  StreamSink<InfoWindowEntity> sink;
  AnimationController controller;
  double opacity;
  MainChartStyle mainChartStyle;
  SubChartStyle subChartStyle;
  List<MALine> maLine;

  // MainChartSetting mainSetting;
  // VolChartSetting volSetting;
  // SecondaryChartSetting secondarySetting;

  ChartPainter({
    @required datas,
    @required scaleX,
    @required scrollX,
    @required isLongPass,
    @required selectX,
    @required selectY,
    ChartLongPressY longPressY,
    mainState,
    volState,
    secondaryState,
    this.sink,
    bool isLine,
    this.controller,
    this.opacity = 0.0,
    MainChartStyle mainStyle,
    SubChartStyle subStyle,
    ValueChanged<double> onCalculateMaxScrolled,
    this.maLine,
    // MainChartSetting mainSetting,
    // VolChartSetting volSetting,
    // SecondaryChartSetting secondarySetting,
  })  : this.mainChartStyle = mainStyle ?? MainChartStyle.light(),
        this.subChartStyle = subStyle ?? SubChartStyle.light(),
        // this.mainSetting = mainSetting ?? MainChartSetting(),
        // this.volSetting = volSetting ?? VolChartSetting(),
        // this.secondarySetting = secondarySetting ?? SecondaryChartSetting(),
        super(
          datas: datas,
          scaleX: scaleX,
          scrollX: scrollX,
          isLongPress: isLongPass,
          longPressY: longPressY,
          selectX: selectX,
          selectY: selectY,
          mainState: mainState,
          volState: volState,
          secondaryState: secondaryState,
          isLine: isLine,
          onCalculateMaxScrolled: onCalculateMaxScrolled,
        );

  @override
  void initChartRenderer() {
    // print('初始化: $mMainMinValue');
    KLineEntity preEntity, nextEntity;
    var preIndex = mStartIndex - 1;
    var nextIndex = mStopIndex + 1;
    if (preIndex >= 0 && preIndex < datas.length) {
      preEntity = datas[preIndex];
    }
    if (nextIndex >= 0 && nextIndex < datas.length) {
      nextEntity = datas[nextIndex];
    }

    mMainRenderer ??= MainRenderer(
      mMainRect,
      mMainMaxValue,
      mMainMinValue,
      ChartStyle.topPadding,
      mainState,
      isLine,
      scaleX,
      mainChartStyle,
      maLine,
      preEntity,
      nextEntity,
    );
    if (mVolRect != null) {
      mVolRenderer ??= VolRenderer(
        mVolRect,
        mVolMaxValue,
        mVolMinValue,
        ChartStyle.childPadding,
        scaleX,
        mainChartStyle,
      );
    }
    if (mSecondaryRect != null) {
      mSecondaryRenderer ??= SecondaryRenderer(
        mSecondaryRect,
        mSecondaryMaxValue,
        mSecondaryMinValue,
        ChartStyle.childPadding,
        secondaryState,
        scaleX,
        subChartStyle,
        mainChartStyle,
      );
    }
  }

  final Paint mBgPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    mBgPaint.color = mainChartStyle.bgColor;
    selectPointPaint.color = mainChartStyle.markerBgColor;
    selectorBorderPaint.color = mainChartStyle.markerBorderColor;
    super.paint(canvas, size);
  }

  @override
  void drawBg(Canvas canvas, Size size) {
    if (mMainRect != null) {
      Rect mainRect = Rect.fromLTRB(
          0, 0, mMainRect.width, mMainRect.height + ChartStyle.topPadding);
      canvas.drawRect(mainRect, mBgPaint);
    }

    if (mVolRect != null) {
      Rect volRect = Rect.fromLTRB(
        0,
        mVolRect.top - ChartStyle.childPadding,
        mVolRect.width,
        mVolRect.bottom,
      );
      canvas.drawRect(volRect, mBgPaint);
    }

    if (mSecondaryRect != null) {
      Rect secondaryRect = Rect.fromLTRB(
          0,
          mSecondaryRect.top - ChartStyle.childPadding,
          mSecondaryRect.width,
          mSecondaryRect.bottom);
      canvas.drawRect(secondaryRect, mBgPaint);
    }
    Rect dateRect = Rect.fromLTRB(
        0, size.height - ChartStyle.bottomDateHigh, size.width, size.height);
    canvas.drawRect(dateRect, mBgPaint);
  }

  @override
  void drawGrid(canvas) {
    mMainRenderer?.drawGrid(
      canvas,
      ChartStyle.gridRows,
      ChartStyle.gridColumns,
    );
    mVolRenderer?.drawGrid(
      canvas,
      ChartStyle.gridRows,
      ChartStyle.gridColumns,
    );
    mSecondaryRenderer?.drawGrid(
      canvas,
      ChartStyle.gridRows,
      ChartStyle.gridColumns,
    );
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    // canvas.save();
    // print('位移: $mTranslateX');
    // var mainTransRect = mMainRect
    //     .translate((mTranslateX * scaleX).abs(), 0.0)
    //     .scale(scaleX, 1.0);
    // var volTransRect = mVolRect
    //     .translate((mTranslateX * scaleX).abs(), 0.0)
    //     .scale(scaleX, 1.0);
    // var secondaryTransRect = mSecondaryRect
    //     .translate((mTranslateX * scaleX).abs(), 0.0)
    //     .scale(scaleX, 1.0);
    // // print('切割: $mMainRect, 偏移: ${mTranslateX * scaleX}, 偏移後: $mainTransRect');
    // canvas.translate(mTranslateX * scaleX, 0.0);
    //
    // // canvas的縮放錨點默認為左上角
    // canvas.scale(scaleX, 1.0);
    // print('縮放 = $scaleX');

    void drawMain() {
      canvas.save();
      // canvas.clipRect(mainTransRect);
      canvas.clipRect(mMainRect);
      canvas.translate(mTranslateX * scaleX, 0.0);
      canvas.scale(scaleX, 1.0);
      for (int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
        KLineEntity curPoint = datas[i];
        if (curPoint == null) continue;
        KLineEntity lastPoint = i == 0 ? curPoint : datas[i - 1];
        double curX = getX(i);
        double lastX = i == 0 ? curX : getX(i - 1);
        mMainRenderer?.drawChart(
            lastPoint, curPoint, lastX, curX, size, canvas);
      }
      canvas.restore();
    }

    void drawVol() {
      canvas.save();
      canvas.clipRect(mVolRect);
      canvas.translate(mTranslateX * scaleX, 0.0);
      canvas.scale(scaleX, 1.0);
      for (int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
        KLineEntity curPoint = datas[i];
        if (curPoint == null) continue;
        KLineEntity lastPoint = i == 0 ? curPoint : datas[i - 1];
        double curX = getX(i);
        double lastX = i == 0 ? curX : getX(i - 1);
        mVolRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      }
      canvas.restore();
    }

    void drawSecondary() {
      canvas.save();
      canvas.clipRect(mSecondaryRect);
      canvas.translate(mTranslateX * scaleX, 0.0);
      canvas.scale(scaleX, 1.0);
      for (int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
        KLineEntity curPoint = datas[i];
        if (curPoint == null) continue;
        KLineEntity lastPoint = i == 0 ? curPoint : datas[i - 1];
        double curX = getX(i);
        double lastX = i == 0 ? curX : getX(i - 1);
        mSecondaryRenderer?.drawChart(
            lastPoint, curPoint, lastX, curX, size, canvas);
      }
      canvas.restore();
    }

    void drawCrossLine() {
      canvas.save();
      canvas.translate(mTranslateX * scaleX, 0.0);
      canvas.scale(scaleX, 1.0);
      var index = calculateSelectedX(selectX);
      Paint paintY = Paint()
        ..color = mainChartStyle.markerVerticalLineColor
        ..strokeWidth = ChartStyle.vCrossWidth
        ..isAntiAlias = true;
      double x = getX(index);
      double y;

      switch (longPressY) {
        case ChartLongPressY.absolute:
          y = clampY(selectY);
          break;
        case ChartLongPressY.gridAdsorption:
          y = getGridAdsorption(selectY);
          y = clampY(y);
          break;
        case ChartLongPressY.closePrice:
          KLineEntity point = getItem(index);
          y = getMainY(point.close);
          break;
      }

      // print('y軸位置: $selectY, 繪製y: $y');

      // k线图竖线
      canvas.drawLine(
        Offset(x, ChartStyle.topPadding),
        Offset(x, size.height - ChartStyle.bottomDateHigh),
        paintY,
      );

      Paint paintX = Paint()
        ..color = mainChartStyle.markerHorizontalLineColor
        ..strokeWidth = ChartStyle.hCrossWidth
        ..isAntiAlias = true;
      // k线图横线
      canvas.drawLine(
        Offset(-mTranslateX, y),
        Offset(-mTranslateX + mWidth / scaleX, y),
        paintX,
      );
//    canvas.drawCircle(Offset(x, y), 2.0, paintX);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(x, y), height: 2.0 * scaleX, width: 2.0),
          paintX);
      canvas.restore();
    }

    drawMain();
    drawVol();
    drawSecondary();

    if (isLongPress == true) drawCrossLine();
    // canvas.restore();
  }

  @override
  void drawRightText(canvas) {
    var textStyle = getTextStyle(mainChartStyle.yAxisTextColor);
    mMainRenderer?.drawRightText(canvas, textStyle, ChartStyle.gridRows);
    mVolRenderer?.drawRightText(canvas, textStyle, ChartStyle.gridRows);
    mSecondaryRenderer?.drawRightText(canvas, textStyle, ChartStyle.gridRows);
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    double columnSpace = size.width / ChartStyle.gridColumns;
    double startX = getX(mStartIndex) - mPointWidth / 2;
    double stopX = getX(mStopIndex) + mPointWidth / 2;
    double y = 0.0;
    for (var i = 0; i <= ChartStyle.gridColumns; ++i) {
      double translateX = xToTranslateX(columnSpace * i);
      if (translateX >= startX && translateX <= stopX) {
        int index = indexOfTranslateX(translateX);
        if (datas[index] == null) continue;
        TextPainter tp = getTextPainter(
          getDate(datas[index].dateTime),
          color: mainChartStyle.xAxisTextColor,
        );
        y = size.height -
            (ChartStyle.bottomDateHigh - tp.height) / 2 -
            tp.height;
        tp.paint(canvas, Offset(columnSpace * i - tp.width / 2, y));
      }
    }
  }

  Paint selectPointPaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.5;

  Paint selectorBorderPaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  @override
  void drawCrossLineText(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);

    double y;
    switch (longPressY) {
      case ChartLongPressY.absolute:
        y = clampY(selectY);
        break;
      case ChartLongPressY.gridAdsorption:
        y = getGridAdsorption(selectY);
        y = clampY(y);
        break;
      case ChartLongPressY.closePrice:
        y = getMainY(point.close);
        break;
    }

    TextPainter tp = getTextPainter(
      format(getMainValue(y)),
      color: mainChartStyle.markerHorizontalTextColor,
    );
    double textHeight = tp.height;
    double textWidth = tp.width;

    double w1 = 5;
    double w2 = 3;
    double r = textHeight / 2 + w2;
    // double y = getMainY(point.close);
    // double y = selectY;
    double x;
    bool isLeft = false;
    if (translateXtoX(getX(index)) < mWidth / 2) {
      isLeft = false;
      x = 1;
      Path path = new Path();
      path.moveTo(x, y - r);
      path.lineTo(x, y + r);
      path.lineTo(textWidth + 2 * w1, y + r);
      path.lineTo(textWidth + 2 * w1 + w2, y);
      path.lineTo(textWidth + 2 * w1, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1, y - textHeight / 2));
    } else {
      isLeft = true;
      x = mWidth - textWidth - 1 - 2 * w1 - w2;
      Path path = new Path();
      path.moveTo(x, y);
      path.lineTo(x + w2, y + r);
      path.lineTo(mWidth - 2, y + r);
      path.lineTo(mWidth - 2, y - r);
      path.lineTo(x + w2, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1 + w2, y - textHeight / 2));
    }

    TextPainter dateTp = getTextPainter(
      getDate(point.dateTime),
      color: mainChartStyle.markerVerticalTextColor,
    );
    textWidth = dateTp.width;
    r = textHeight / 2;
    x = translateXtoX(getX(index));
    y = size.height - ChartStyle.bottomDateHigh;

    if (x < textWidth + 2 * w1) {
      x = 1 + textWidth / 2 + w1;
    } else if (mWidth - x < textWidth + 2 * w1) {
      x = mWidth - 1 - textWidth / 2 - w1;
    }
    double baseLine = textHeight / 2;
    canvas.drawRect(
        Rect.fromLTRB(
          x - textWidth / 2 - w1,
          y,
          x + textWidth / 2 + w1,
          y + baseLine + r,
        ),
        selectPointPaint);
    canvas.drawRect(
        Rect.fromLTRB(
          x - textWidth / 2 - w1,
          y,
          x + textWidth / 2 + w1,
          y + baseLine + r,
        ),
        selectorBorderPaint);

    dateTp.paint(canvas, Offset(x - textWidth / 2, y));
    //长按显示这条数据详情
    sink?.add(InfoWindowEntity(point, isLeft));
  }

  @override
  void drawText(Canvas canvas, KLineEntity data, double x) {
    //长按显示按中的数据
    if (isLongPress) {
      var index = calculateSelectedX(selectX);
      data = getItem(index);
    }
    //松开显示最后一条数据
    mMainRenderer?.drawText(canvas, data, x);
    mVolRenderer?.drawText(canvas, data, x);
    mSecondaryRenderer?.drawText(canvas, data, x);
  }

  @override
  void drawMaxAndMin(Canvas canvas) {
    if (isLine == true) return;
    //绘制最大值和最小值
    double x = translateXtoX(getX(mMainMinIndex));
    double y = getMainY(mMainLowMinValue);
    if (x < mWidth / 2) {
      //画右边
      TextPainter tp = getTextPainter(
        "── ${format(mMainLowMinValue)}",
        color: mainChartStyle.minTextColor,
      );
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      TextPainter tp = getTextPainter(
        "${format(mMainLowMinValue)} ──",
        color: mainChartStyle.minTextColor,
      );
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
    x = translateXtoX(getX(mMainMaxIndex));
    y = getMainY(mMainHighMaxValue);
    if (x < mWidth / 2) {
      //画右边
      TextPainter tp = getTextPainter(
        "── ${format(mMainHighMaxValue)}",
        color: mainChartStyle.maxTextColor,
      );
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      TextPainter tp = getTextPainter(
        "${format(mMainHighMaxValue)} ──",
        color: mainChartStyle.maxTextColor,
      );
      // print('繪製最高價格 = $y');
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
  }

  final Paint realTimePaint = Paint()
        ..strokeWidth = 1.0
        ..isAntiAlias = true,
      pointPaint = Paint();

  ///画实时价格线
  @override
  void drawRealTimePrice(Canvas canvas, Size size) {
    if (mMarginRight == 0 || datas?.isEmpty == true) return;
    KLineEntity point = datas.last;
    TextPainter tp = getTextPainter(
      format(point.close),
      color: mainChartStyle.rightRealTimeTextColor,
    );
    double y = getMainY(point.close);
    //max越往右边滑值越小
    var max = (mTranslateX.abs() +
            mMarginRight -
            getMinTranslateX().abs() +
            mPointWidth) *
        scaleX;
    double x = mWidth - max;
    if (!isLine) x += mPointWidth / 2;
    var dashWidth = 10;
    var dashSpace = 5;
    double startX = 0;
    final space = (dashSpace + dashWidth);
    if (tp.width < max) {
      while (startX < max) {
        canvas.drawLine(
          Offset(x + startX, y),
          Offset(x + startX + dashWidth, y),
          realTimePaint..color = mainChartStyle.rightRealTimeLineColor,
        );
        startX += space;
      }
      //画一闪一闪
      if (isLine) {
        startAnimation();
        var colors = List.of(mainChartStyle.rightRealTimeFlashPointColor);
        colors[0] = colors[0].withOpacity(opacity ?? 0.0);
        Gradient pointGradient = RadialGradient(colors: colors);
        pointPaint.shader = pointGradient
            .createShader(Rect.fromCircle(center: Offset(x, y), radius: 14.0));
        canvas.drawCircle(Offset(x, y), 14.0, pointPaint);
        canvas.drawCircle(
            Offset(x, y), 2.0, realTimePaint..color = Colors.white);
      } else {
        stopAnimation(); //停止一闪闪
      }
      double left = mWidth - tp.width;
      double top = y - tp.height / 2;
      canvas.drawRect(
        Rect.fromLTRB(left, top, left + tp.width, top + tp.height),
        realTimePaint..color = mainChartStyle.rightRealTimeBgColor,
      );
      tp.paint(canvas, Offset(left, top));
    } else {
      stopAnimation(); //停止一闪闪
      startX = 0;
      if (point.close > mMainMaxValue) {
        y = getMainY(mMainMaxValue);
      } else if (point.close < mMainMinValue) {
        y = getMainY(mMainMinValue);
      }
      while (startX < mWidth) {
        canvas.drawLine(
          Offset(startX, y),
          Offset(startX + dashWidth, y),
          realTimePaint..color = mainChartStyle.realTimeLineColor,
        );
        startX += space;
      }

      const padding = 3.0;
      const triangleHeight = 8.0; //三角高度
      const triangleWidth = 5.0; //三角宽度

      double left =
          mWidth - mWidth / ChartStyle.gridColumns - tp.width / 2 - padding * 2;
      double top = y - tp.height / 2 - padding;
      //加上三角形的宽以及padding
      double right = left + tp.width + padding * 2 + triangleWidth + padding;
      double bottom = top + tp.height + padding * 2;
      double radius = (bottom - top) / 2;
      //画椭圆背景
      RRect rectBg1 =
          RRect.fromLTRBR(left, top, right, bottom, Radius.circular(radius));
      RRect rectBg2 = RRect.fromLTRBR(left - 1, top - 1, right + 1, bottom + 1,
          Radius.circular(radius + 2));
      canvas.drawRRect(
        rectBg2,
        realTimePaint..color = mainChartStyle.realTimeTextBorderColor,
      );
      canvas.drawRRect(
        rectBg1,
        realTimePaint..color = mainChartStyle.realTimeBgColor,
      );
      tp = getTextPainter(
        format(point.close),
        color: mainChartStyle.realTimeTextColor,
      );
      Offset textOffset = Offset(left + padding, y - tp.height / 2);
      tp.paint(canvas, textOffset);
      //画三角
      Path path = Path();
      double dx = tp.width + textOffset.dx + padding;
      double dy = top + (bottom - top - triangleHeight) / 2;
      path.moveTo(dx, dy);
      path.lineTo(dx + triangleWidth, dy + triangleHeight / 2);
      path.lineTo(dx, dy + triangleHeight);
      path.close();
      canvas.drawPath(
          path,
          realTimePaint
            ..color = mainChartStyle.realTimeTriangleColor
            ..shader = null);
    }
  }

  TextPainter getTextPainter(text, {color = Colors.white}) {
    TextSpan span = TextSpan(text: "$text", style: getTextStyle(color));
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  String getDate(DateTime date) => dateFormat(date, mFormats);

  double getMainY(double y) => mMainRenderer?.getY(y) ?? 0.0;

  double getMainValue(double y) {
    return mMainRenderer?.getValue(y) ?? 0.0;
  }

  double getGridAdsorption(double y) {
    if (mMainRenderer != null && mMainRenderer is MainRenderer) {
      return (mMainRenderer as MainRenderer).getGridAdsorption(y);
    } else {
      return y;
    }
  }

  /// 限制y軸範圍
  double clampY(double y) {
    if (mMainRenderer != null && mMainRenderer is MainRenderer) {
      var gridPos = (mMainRenderer as MainRenderer).gridPosition;
      if (gridPos.length >= 2) {
        var minY = gridPos.first;
        var maxY = gridPos.last;
        return y.clamp(minY, maxY);
      } else {
        return y;
      }
    } else {
      return y;
    }
  }

  startAnimation() {
    if (controller?.isAnimating != true) controller?.repeat(reverse: true);
  }

  stopAnimation() {
    if (controller?.isAnimating == true) controller?.stop();
  }
}

extension _ScaleRect on Rect {
  Rect scale(double sx, [double sy = 1]) {
    return Rect.fromLTWH(
      this.left,
      this.top,
      this.width.multiply(sx),
      this.height.multiply(sy),
    );
  }
}
