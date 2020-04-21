import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'animated_value/comb.dart';

export 'animated_value/comb.dart';

part 'animated_comb_controller.dart';

part 'animated_sync_tick.dart';

part 'shift_animation.dart';

typedef ToggleWidgetBuilder = Widget Function(
  BuildContext context,
  bool toggle,
);

/// 多動畫組合
class AnimatedComb extends StatefulWidget {
  final Widget child;

  /// 動畫列表 - 整個列表動畫是串連的行為
  /// <p>主要由以下幾種動畫構成</p>
  /// [Comb.parallel] - 並行動畫
  /// [Comb.rotateX] - 垂直翻轉動畫
  /// [Comb.rotateY] - 水平翻轉動畫
  /// [Comb.rotateZ] - 旋轉動畫
  /// [Comb.opacity] - 透明動畫
  /// [Comb.scale] - 縮放 width, height 動畫
  /// [Comb.scaleX] - 縮放 width 動畫
  /// [Comb.scaleY] - 縮放 height 動畫
  /// [Comb.translate] - 位移動畫
  /// [Comb.translateX] - x軸位移動畫
  /// [Comb.translateY] - y軸位移動畫
  /// [Comb.width] - 寬度size動畫
  /// [Comb.height] - 高度size動畫
  /// [Comb.color] - 背景色變換動畫
  final List<Comb> animatedList;

  /// 若此元件會放在重複使用的列表 (List / Grid / Sliver) 裡面, 則帶入 true
  /// <p>具體說明</p>
  /// 在此元素樹生命週期內, 是否有多個 AnimationController
  /// 此參數影響到使用動畫的為 [SingleTickerProviderStateMixin] 或 [TickerProviderStateMixin]
  /// 若生命週期內只有單個請使用 [SingleTickerProviderStateMixin] 效率較高
  /// 若有多個請使用 [TickerProviderStateMixin]
  final bool multipleAnimationController;

  /// 動畫的預設錨點
  final Alignment alignment;

  /// 動畫的預設差值器
  final Curve curve;

  /// 動畫的預設 duration
  final int duration;

  /// 動畫開始偏移時間
  /// 若 [shiftDuration] 為負, 則 動畫起始的狀態將會是 [shiftDuration] 前的狀態
  /// 若 [shiftDuration] 為正, 則 動畫起始的狀態將會是 [shiftDuration] 後的狀態
  final int shiftDuration;

  /// 點擊回調
  final VoidCallback onTap;

  /// 點擊動畫回覆後回調
  final VoidCallback onTapAfterAnimated;

  /// 動畫操作與轉換核心
  /// 由此類控制將 [animatedList] 轉化為真正執行的動畫數值
  /// 以及操控動畫的行為
  /// 同時也可透過外部傳入此類, 達到多個元件擁有同樣的動畫操作 tick
  ///
  /// 若外部只是單純需要操控單個元件, 則使用帶入 [AnimatedSyncTick.identity] 工廠方法構建 tick
  /// 若需要多個元件同步 tick, 則直接呼叫 AnimatedSyncTick 建構子
  final AnimatedSyncTick animatedSyncTick;

  /// toggle 的行為模式中,可根據 toggle 值設定不同的 child
  final ToggleWidgetBuilder toggleBuilder;

  /// 動畫類型
  final AnimatedType type;

  AnimatedComb._({
    Key key,
    @required this.child,
    this.multipleAnimationController = false,
    this.animatedSyncTick,
    this.type,
    this.curve = Curves.easeInOut,
    this.shiftDuration = 0,
    this.duration = 300,
    this.alignment = FractionalOffset.center,
    this.onTap,
    this.onTapAfterAnimated,
    this.toggleBuilder,
    @required this.animatedList,
  }) : super(key: key);

  /// 可深層訂製動畫組合
  /// [sync] 以及 [type] 皆有值時, 以 [sync.type] 為主
  factory AnimatedComb({
    Key key,
    @required Widget child,
    AnimatedSyncTick sync,
    AnimatedType type,
    bool multipleAnimationController = false,
    Curve curve = Curves.easeInOut,
    int duration = 300,
    int shiftDuration = 0,
    Alignment alignment = FractionalOffset.center,
    VoidCallback onTap,
    VoidCallback onTapAfterAnimated,
    ToggleWidgetBuilder toggleBuilder,
    @required List<Comb> animatedList,
  }) {
    return AnimatedComb._(
      key: key,
      child: child,
      multipleAnimationController: multipleAnimationController,
      animatedSyncTick: sync,
      type: type,
      curve: curve,
      duration: duration,
      shiftDuration: shiftDuration,
      alignment: alignment,
      onTap: onTap,
      onTapAfterAnimated: onTapAfterAnimated,
      toggleBuilder: toggleBuilder,
      animatedList: animatedList,
    );
  }

  /// 快速設置併發且多元件同步的動畫
  /// [sync] 以及 [type] 皆有值時, 以 [sync.type] 為主
  factory AnimatedComb.quick({
    Key key,
    @required Widget child,
    AnimatedSyncTick sync,
    AnimatedType type,
    bool multipleAnimationController = false,
    Curve curve = Curves.easeInOut,
    int duration = 300,
    int shiftDuration = 0,
    Alignment alignment = FractionalOffset.center,
    VoidCallback onTap,
    VoidCallback onTapAfterAnimated,
    ToggleWidgetBuilder toggleBuilder,
    CombRotate rotate,
    CombOpacity opacity,
    CombScale scale,
    CombTranslate translate,
    CombSize size,
    CombColor color,
  }) {
    List<Comb> animateList = [];
    if (rotate != null) animateList.add(rotate);
    if (opacity != null) animateList.add(opacity);
    if (scale != null) animateList.add(scale);
    if (translate != null) animateList.add(translate);
    if (size != null) animateList.add(size);
    if (color != null) animateList.add(color);

    return AnimatedComb(
      key: key,
      child: child,
      multipleAnimationController: multipleAnimationController,
      sync: sync,
      curve: curve,
      type: type,
      duration: duration,
      shiftDuration: shiftDuration,
      alignment: alignment,
      onTap: onTap,
      onTapAfterAnimated: onTapAfterAnimated,
      toggleBuilder: toggleBuilder,
      animatedList: [Comb.parallel(animatedList: animateList)],
    );
  }

  @override
  _CombState createState() =>
      multipleAnimationController ? _MultipleCombState() : _SingleCombState();
}

abstract class _CombState extends State<AnimatedComb>
    implements TickerProvider {
  /// 當前的動畫 tick
  AnimatedSyncTick _currentAnimatedTick;

  /// 當前的動畫是否已經初始化完成
  bool isAnimatedInitComplete = false;

  /// 註冊動畫列表到 [AnimatedSyncTick] 後得到的 id
  int _syncAnimateId;

  /// 動畫 tick 監聽
  StreamSubscription _tickStreamSubscription;

  /// sync tick 的綁定方式
  /// 會決定到 dispose 時控制器的釋放與否
  _SyncTickBindingType _syncTickBindingType;

  @override
  void initState() {
    if (widget.animatedSyncTick == null) {
      _syncTickBindingType = _SyncTickBindingType.inside;
      _currentAnimatedTick = AnimatedSyncTick(type: widget.type, vsync: this);
    } else if (widget.animatedSyncTick._isNeedRegisterTicker) {
      _syncTickBindingType = _SyncTickBindingType.outsideNeedReset;
      // 外部單純帶入控制器, 在此進行 ticker 註冊
      widget.animatedSyncTick._registerTicker(widget.type, this);
      _currentAnimatedTick = widget.animatedSyncTick;
    } else {
      _syncTickBindingType = _SyncTickBindingType.outsideSelf;
      _currentAnimatedTick = widget.animatedSyncTick;
    }

    _initAnimated();

    _tickStreamSubscription = _currentAnimatedTick.tickStream.listen((_) {
      setState(() {});
    });

    _currentAnimatedTick._start();

    super.initState();
  }

  @override
  void didUpdateWidget(AnimatedComb oldWidget) {
    if (_isNeedUpdate(oldWidget)) {
      _initAnimated();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// 初始化動畫行為與數值
  /// 同時註冊動畫到 [animatedSyncTick]
  void _initAnimated() {
    // 註冊動畫到 [animatedSyncTick]
    _syncAnimateId = _currentAnimatedTick._registerAnimated(
      animateList: widget.animatedList,
      duration: widget.duration,
      curve: widget.curve,
      id: _syncAnimateId,
      shiftDuration: widget.shiftDuration ?? 0,
    );
  }

  /// 檢查新舊兩個 widget 是否一樣
  bool _isNeedUpdate(AnimatedComb oldWidget) {
    if (oldWidget.type != widget.type ||
        oldWidget.duration != widget.duration ||
        oldWidget.curve != widget.curve ||
        oldWidget.alignment != widget.alignment) {
      return true;
    }

    // 最後再檢查動畫是否一樣
    var isLenSame = oldWidget.animatedList.length == widget.animatedList.length;
    var isInsSame = true;
    if (isLenSame) {
      for (var i = 0; i < oldWidget.animatedList.length; i++) {
        isInsSame = oldWidget.animatedList[i] == widget.animatedList[i];
        if (!isInsSame) break;
      }
    }

    return !isLenSame || !isInsSame;
  }

  @override
  Widget build(BuildContext context) {
    Widget childChain;

    if (_currentAnimatedTick.type == AnimatedType.toggle &&
        widget.toggleBuilder != null) {
      childChain =
          widget.toggleBuilder(context, _currentAnimatedTick._currentToggle);
    } else {
      childChain = widget.child;
    }

    var animationData = _currentAnimatedTick._getAnimationData(_syncAnimateId);

    Matrix4 transform = Matrix4.identity();

    if (animationData.currentRotateX != null) {
      transform.rotateX(animationData.currentRotateX);
    }

    if (animationData.currentRotateY != null) {
      transform.rotateY(animationData.currentRotateY);
    }

    if (animationData.currentRotateZ != null) {
      transform.rotateZ(animationData.currentRotateZ);
    }

    if (animationData.currentOffset != null) {
      transform.translate(
          animationData.currentOffset.dx, animationData.currentOffset.dy);
    }

    if (animationData.currentScale != null) {
      transform.scale(
          animationData.currentScale.width, animationData.currentScale.height);
    }

    childChain = _appendTransform(childChain, transform, widget.alignment);

    // 添加透明動畫
    childChain = Opacity(
      opacity: animationData.currentOpacity ?? 1,
      child: childChain,
    );

    // 添加 size 動畫
    childChain = Container(
      color: animationData.currentColor,
      width: animationData.currentSize?.width,
      height: animationData.currentSize?.height,
      child: childChain,
    );

    // 檢查並添加點擊行為
    if (_currentAnimatedTick.type == AnimatedType.tap) {
      childChain = GestureDetector(
        child: childChain,
        onTapDown: (_) => _currentAnimatedTick._forward(),
        onTapUp: (_) async {
          await _currentAnimatedTick._reverse();
          if (widget.onTapAfterAnimated != null) {
            widget.onTapAfterAnimated();
          }
        },
        onTapCancel: () => _currentAnimatedTick._reverse(),
        onTap: widget.onTap,
      );
    } else if (widget.onTap != null) {
      childChain = GestureDetector(
        child: childChain,
        onTap: widget.onTap,
      );
    }

    return childChain;
  }

  /// 添加一個動畫數值到 Transform 元件
  Widget _appendTransform(
    Widget child,
    Matrix4 transform,
    Alignment alignment,
  ) {
    return Transform(
      alignment: alignment,
      transform: transform,
      child: child,
    );
  }
}

class _SingleCombState extends _CombState with SingleTickerProviderStateMixin {
  /// controller 需要在 super.dispose 之前釋放
  /// 但奇怪的是寫在 [_TapState] 也無法正常釋放, 因此放在此處
  /// 因此無法寫在 [_TapState] 的 dispose 方法內
  @override
  void dispose() {
    switch (_syncTickBindingType) {
      case _SyncTickBindingType.outsideSelf:
        // 由外部自行處理
        break;
      case _SyncTickBindingType.outsideNeedReset:
        _currentAnimatedTick._reset();
        _currentAnimatedTick = null;
        break;
      case _SyncTickBindingType.inside:
        _currentAnimatedTick.dispose();
        _currentAnimatedTick = null;
        break;
    }
    _tickStreamSubscription?.cancel();
    _tickStreamSubscription = null;
    super.dispose();
  }
}

class _MultipleCombState extends _CombState with TickerProviderStateMixin {
  /// 說明參考 [_SingleToggleState] 的 dispose
  @override
  void dispose() {
    switch (_syncTickBindingType) {
      case _SyncTickBindingType.outsideSelf:
      // 由外部自行處理
        break;
      case _SyncTickBindingType.outsideNeedReset:
        _currentAnimatedTick._reset();
        _currentAnimatedTick = null;
        break;
      case _SyncTickBindingType.inside:
        _currentAnimatedTick.dispose();
        _currentAnimatedTick = null;
        break;
    }
    _tickStreamSubscription?.cancel();
    _tickStreamSubscription = null;
    super.dispose();
  }
}

/// sync 的 ticker 綁定方式
enum _SyncTickBindingType {
  /// 由外部傳入, ticker 也綁定在外部
  outsideSelf,

  /// 由外部傳入, 純控制器, ticker 綁定在 [AnimatedComb] 上
  /// 在 [AnimatedComb] dispose 時需要進行 reset
  outsideNeedReset,

  /// 內部自行創建, 因此 dispose 時需要跟著 dispose
  inside,
}
