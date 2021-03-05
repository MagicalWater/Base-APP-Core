import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'chart_style.dart';
import 'entity/info_window_entity.dart';
import 'entity/k_line_entity.dart';
import 'renderer/chart_painter.dart';
import 'utils/date_format_util.dart';
import 'utils/number_util.dart';

enum MainState { MA, BOLL, NONE }
enum VolState { VOL, NONE }
enum SecondaryState { MACD, KDJ, RSI, WR, NONE }

class TooltipPrefix {
  final String time;
  final String open;
  final String high;
  final String low;
  final String close;
  final String changeValue;
  final String changeRate;
  final String volume;

  const TooltipPrefix({
    this.time = 'time',
    this.open = 'open',
    this.high = 'high',
    this.low = 'low',
    this.close = 'close',
    this.changeValue = 'change',
    this.changeRate = 'changeRate',
    this.volume = 'volume',
  });
}

/// 原作者: https://github.com/gwhcn/flutter_k_chart
///
/// 修改者: Water
/// 修改內容: 針對圖表樣式的配置, 以及新增加載更多的回調
/// 後續優化以及重構在了解整個圖表的架構以及原理後開始
///
class KChart extends StatefulWidget {
  final List<KLineEntity> datas;
  final MainState mainState;
  final VolState volState;
  final SecondaryState secondaryState;
  final bool isLine;
  final MainChartStyle mainStyle;
  final SubChartStyle subStyle;
  final TooltipPrefix tooltipPrefix;

  // 滑動邊緣調用, false代表滑動到最左邊, true則為最右邊
  final Function(bool isRight) onLoadMore;

  KChart(
    this.datas, {
    this.mainState = MainState.MA,
    this.volState = VolState.VOL,
    this.secondaryState = SecondaryState.MACD,
    this.isLine,
    int fractionDigits = 2,
    this.mainStyle = const MainChartStyle.light(),
    this.subStyle = const SubChartStyle.light(),
    this.tooltipPrefix = const TooltipPrefix(),
    this.onLoadMore,
  }) {
    NumberUtil.fractionDigits = fractionDigits;
  }

  @override
  _KChartState createState() => _KChartState();
}

class _KChartState extends State<KChart> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;
  StreamController<InfoWindowEntity> mInfoWindowStream;
  double mWidth = 0;
  AnimationController _scrollXController;

  double getMinScrollX() {
    return mScaleX;
  }

  double _lastScale = 1.0;
  bool isScale = false, isDrag = false, isLongPress = false;

  @override
  void initState() {
    super.initState();
    _syncTooltipShow();
    mInfoWindowStream = StreamController<InfoWindowEntity>();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 850), vsync: this);
    _animation = Tween(begin: 0.9, end: 0.1).animate(_controller)
      ..addListener(() => setState(() {}));
    _scrollXController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        lowerBound: double.negativeInfinity,
        upperBound: double.infinity);
    _scrollListener();
  }

  void _syncTooltipShow() {
    var tip = widget.tooltipPrefix;
    infoNames = [
      tip.time,
      tip.open,
      tip.high,
      tip.low,
      tip.close,
      tip.changeValue,
      tip.changeRate,
      tip.volume
    ];
  }

  void _scrollListener() {
    _scrollXController.addListener(() {
      mScrollX = _scrollXController.value;
      if (mScrollX <= 0) {
        mScrollX = 0;
        widget.onLoadMore?.call(true);
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        widget.onLoadMore?.call(false);
        _stopAnimation();
      } else {
        notifyChanged();
      }
    });
    _scrollXController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        isDrag = false;
        notifyChanged();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mWidth = MediaQuery.of(context).size.width;
  }

  @override
  void didUpdateWidget(KChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTooltipShow();
    if (oldWidget.datas != widget.datas) mScrollX = mSelectX = 0.0;
  }

  @override
  void dispose() {
    mInfoWindowStream?.close();
    _controller?.dispose();
    _scrollXController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas == null || widget.datas.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }
    return GestureDetector(
      onHorizontalDragDown: (details) {
        _stopAnimation();
        isDrag = true;
      },
      onHorizontalDragUpdate: (details) {
        if (isScale || isLongPress) return;
        mScrollX = (details.primaryDelta / mScaleX + mScrollX)
            .clamp(0.0, ChartPainter.maxScrollX);
        notifyChanged();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        // isDrag = false;
        final Tolerance tolerance = Tolerance(
          velocity:
              1.0 / (0.050 * WidgetsBinding.instance.window.devicePixelRatio),
          // logical pixels per second
          distance: 1.0 /
              WidgetsBinding.instance.window.devicePixelRatio, // logical pixels
        );

        ClampingScrollSimulation simulation = ClampingScrollSimulation(
          position: mScrollX,
          velocity: details.primaryVelocity,
          tolerance: tolerance,
        );
        _scrollXController.animateWith(simulation);
      },
      onHorizontalDragCancel: () => isDrag = false,
      onScaleStart: (_) {
        isScale = true;
      },
      onScaleUpdate: (details) {
        if (isDrag || isLongPress) return;
        mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
        notifyChanged();
      },
      onScaleEnd: (_) {
        isScale = false;
        _lastScale = mScaleX;
      },
      onLongPressStart: (details) {
        isLongPress = true;
        if (mSelectX != details.globalPosition.dx) {
          mSelectX = details.globalPosition.dx;
          notifyChanged();
        }
      },
      onLongPressMoveUpdate: (details) {
        if (mSelectX != details.globalPosition.dx) {
          mSelectX = details.globalPosition.dx;
          notifyChanged();
        }
      },
      onLongPressEnd: (details) {
        isLongPress = false;
        mInfoWindowStream?.sink?.add(null);
        notifyChanged();
      },
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: ChartPainter(
              datas: widget.datas,
              scaleX: mScaleX,
              scrollX: mScrollX,
              selectX: mSelectX,
              isLongPass: isLongPress,
              mainState: widget.mainState,
              volState: widget.volState,
              secondaryState: widget.secondaryState,
              isLine: widget.isLine,
              sink: mInfoWindowStream?.sink,
              opacity: _animation.value,
              controller: _controller,
              mainStyle: widget.mainStyle,
              subStyle: widget.subStyle,
            ),
          ),
          _buildInfoDialog(),
        ],
      ),
    );
  }

  void _stopAnimation() {
    if (_scrollXController != null && _scrollXController.isAnimating) {
      _scrollXController.stop();
      isDrag = false;
      notifyChanged();
    }
  }

  void notifyChanged() => setState(() {});

  List<String> infoNames;
  List infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity>(
        stream: mInfoWindowStream?.stream,
        builder: (context, snapshot) {
          if (!isLongPress ||
              widget.isLine == true ||
              !snapshot.hasData ||
              snapshot.data.kLineEntity == null) return Container();
          KLineEntity entity = snapshot.data.kLineEntity;
          double upDown = entity.close - entity.open;
          double upDownPercent = upDown / entity.open * 100;
          infos = [
            getDate(entity.id),
            NumberUtil.format(entity.open),
            NumberUtil.format(entity.high),
            NumberUtil.format(entity.low),
            NumberUtil.format(entity.close),
            "${upDown > 0 ? "+" : ""}${NumberUtil.format(upDown)}",
            "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
            NumberUtil.volFormat(entity.vol)
          ];
          return Align(
            alignment:
                snapshot.data.isLeft ? Alignment.topLeft : Alignment.topRight,
            child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 25),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: widget.mainStyle.tooltipBgColor,
                border: Border.all(
                    color: widget.mainStyle.tooltipBorderColor, width: 0.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(infoNames.length,
                    (i) => _buildItem(infos[i].toString(), infoNames[i])),
              ),
            ),
          );
        });
  }

  Widget _buildItem(String info, String infoName) {
    Color color = widget.mainStyle.tooltipNoUpDownTextColor;
    if (info.startsWith("+"))
      color = widget.mainStyle.upColor;
    else if (info.startsWith("-")) color = widget.mainStyle.downColor;

    return Container(
      constraints: BoxConstraints(
        minWidth: 95,
        maxWidth: 300,
        maxHeight: 14.0,
        minHeight: 14.0,
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "$infoName",
              style: TextStyle(
                color: widget.mainStyle.tooltipPrefixTextColor,
                fontSize: ChartStyle.defaultTextSize,
              ),
            ),
            Expanded(
                child: Container(
              width: 5,
            )),
            Text(
              info,
              style:
                  TextStyle(color: color, fontSize: ChartStyle.defaultTextSize),
            ),
          ],
        ),
      ),
    );
  }

  String getDate(int date) {
    return dateFormat(DateTime.fromMillisecondsSinceEpoch(date * 1000),
        [yy, '-', mm, '-', dd, ' ', HH, ':', nn]);
  }
}
