import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_weather_bg_null_safety/bg/weather_bg.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:flutter_weather_bg_null_safety/utils/print_utils.dart';
import 'package:flutter_weather_bg_null_safety/utils/weather_type.dart';

//// 晴晚&流星层
class WeatherNightStarBg extends StatefulWidget {
  final WeatherType weatherType;

  WeatherNightStarBg({Key? key, required this.weatherType}) : super(key: key);

  @override
  _WeatherNightStarBgState createState() => _WeatherNightStarBgState();
}

class _WeatherNightStarBgState extends State<WeatherNightStarBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_StarParam> _starParams = [];
  WeatherDataState _state = WeatherDataState.init;
  late double width;
  late double height;
  late double widthRatio;

  /// 准备星星的参数信息
  void fetchData() async {
    Size? size = SizeInherited.of(context)?.size;
    width = size?.width ?? double.infinity;
    height = size?.height ?? double.infinity;
    widthRatio = width / 392.0;
    weatherPrint("开始准备星星参数");
    _state = WeatherDataState.loading;
    initStarParams();
    setState(() {
      _controller.repeat();
    });
    _state = WeatherDataState.finish;
  }

  /// 初始化星星参数
  void initStarParams() {
    for (int i = 0; i < 100; i++) {
      var index = Random().nextInt(2);
      _StarParam _starParam = _StarParam(index);
      _starParam.init(width, height, widthRatio);
      _starParams.add(_starParam);
    }
  }

  @override
  void initState() {
    /// 初始化动画信息
    _controller =
        AnimationController(duration: Duration(seconds: 5), vsync: this);
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildWidget() {
    if (_starParams.isNotEmpty &&
        widget.weatherType == WeatherType.sunnyNight) {
      return CustomPaint(
        painter:
            _StarPainter(_starParams, width, height, widthRatio),
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == WeatherDataState.init) {
      fetchData();
    } else if (_state == WeatherDataState.finish) {
      return _buildWidget();
    }
    return Container();
  }
}

class _StarPainter extends CustomPainter {
  final _paint = Paint();
  final List<_StarParam> _starParams;

  final width;
  final height;
  final widthRatio;

  /// 流星的圆角半径
  _StarPainter(this._starParams, this.width, this.height,
      this.widthRatio) {
    _paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 1);
    _paint.color = Colors.white;
    _paint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_starParams.isNotEmpty) {
      for (var param in _starParams) {
        drawStar(param, canvas);
      }
    }
  }

  /// 绘制星星
  void drawStar(_StarParam param, Canvas canvas) {
    canvas.save();
    var identity = ColorFilter.matrix(<double>[
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      param.alpha,
      0,
    ]);
    _paint.colorFilter = identity;
    canvas.scale(param.scale);
    canvas.drawCircle(Offset(param.x, param.y), 3, _paint);
    canvas.restore();
    param.move();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _StarParam {
  /// x 坐标
  late double x;

  /// y 坐标
  late double y;

  /// 透明度值，默认为 0
  double alpha = 0.0;

  /// 缩放
  late double scale;

  /// 是否反向动画
  bool reverse = false;

  /// 当前下标值
  int index;

  late double width;

  late double height;

  late double widthRatio;

  _StarParam(this.index);

  void reset() {
    alpha = 0;
    double baseScale = index == 0 ? 0.7 : 0.5;
    scale = (Random().nextDouble() * 0.1 + baseScale) * widthRatio;
    x = Random().nextDouble() * 1 * width / scale;
    y = Random().nextDouble() * max(0.3 * height, 150);
    reverse = false;
  }

  /// 用于初始参数
  void init(width, height, widthRatio) {
    this.width = width;
    this.height = height;
    this.widthRatio = widthRatio;
    alpha = Random().nextDouble();
    double baseScale = index == 0 ? 0.7 : 0.5;
    scale = (Random().nextDouble() * 0.1 + baseScale) * widthRatio;
    x = Random().nextDouble() * 1 * width / scale;
    y = Random().nextDouble() * max(0.3 * height, 150);
    reverse = false;
  }

  /// 每次绘制完会触发此方法，开始移动
  void move() {
    if (reverse == true) {
      alpha -= 0.01;
      if (alpha < 0) {
        reset();
      }
    } else {
      alpha += 0.01;
      if (alpha > 1.2) {
        reverse = true;
      }
    }
  }
}
