import 'package:annotation_route/route.dart';
import 'package:flutter/material.dart';
import 'package:mx_core/mx_core.dart';
import 'package:mx_core_example/bloc/page/bullet_shape_bloc.dart';
import 'package:mx_core_example/router/route.dart';

@ARoute(url: Pages.bulletShape)
class BulletShapePage extends StatefulWidget {
  final RouteOption option;

  BulletShapePage(this.option) : super();

  @override
  _BulletShapePageState createState() => _BulletShapePageState();
}

class _BulletShapePageState extends State<BulletShapePage> {
  BulletShapeBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<BulletShapeBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      haveAppBar: true,
      title: '子彈渲染',
      child: SafeArea(
        child: Container(
          width: 200,
          height: 200,
          color: Colors.black,
          child: BulletPaint(
            direction: AxisDirection.left,
          ),
        ),
      ),
    );
  }
}
