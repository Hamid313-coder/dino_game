import 'package:dino_game/game_object.dart';
import 'package:dino_game/sprite.dart';
import 'package:flutter/material.dart';

final List<Sprite> _dinoSprites = List.generate(6, (index) {
  return Sprite(
    imagePath: 'assets/images/dino/dino_${index + 1}.png',
    imageHeight: 94,
    imageWidth: 88,
  );
});

class Dino extends GameObject {
  Sprite currentSprite = _dinoSprites[0];
  @override
  Widget render() {
    return Image.asset(currentSprite.imagePath);
  }

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
        screenSize.width / 10,
        screenSize.height / 2 - currentSprite.imageHeight,
        currentSprite.imageWidth.toDouble(),
        currentSprite.imageHeight.toDouble());
  }

  @override
  void update(Duration lastTime, Duration currentTime) {
    currentSprite =
        _dinoSprites[(currentTime.inMilliseconds / 100).floor() % 2 + 2];
  }
}
