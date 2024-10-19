import 'package:flutter/widgets.dart';

abstract class GameObject {
  Widget render();
  Rect getRect(Size screenSize, double runDistance);
  void update(Duration lastTime, Duration currentTime) {}
}
