import 'package:dino_game/constants/constants.dart';
import 'package:dino_game/game_objects/game_object.dart';
import 'package:dino_game/models/sprite.dart';
import 'package:flutter/material.dart';

final List<Sprite> _dinoSprites = List.generate(6, (index) {
  return Sprite(
    imagePath: 'assets/images/dino/dino_${index + 1}.png',
    imageHeight: 94,
    imageWidth: 88,
  );
});

enum DinoState {
  running,
  jumping,
  dead,
}

class Dino extends GameObject {
  Sprite currentSprite = _dinoSprites[0];
  double velY = 0;
  double distanceY = 0;
  DinoState dinoState = DinoState.running;

  @override
  Widget render() {
    return Image.asset(currentSprite.imagePath);
  }

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
        screenSize.width / 10,
        screenSize.height / 2 - currentSprite.imageHeight - distanceY,
        currentSprite.imageWidth.toDouble(),
        currentSprite.imageHeight.toDouble());
  }

  @override
  void update(Duration lastTime, Duration currentTime) {
    currentSprite = dinoState == DinoState.running
        ? _dinoSprites[(currentTime.inMilliseconds / 100).floor() % 2 + 2]
        : _dinoSprites[0];

    double elapsedTimeSecond = (currentTime - lastTime).inMilliseconds / 1000;

    distanceY += velY * elapsedTimeSecond;
    if (distanceY <= 0) {
      velY = 0;
      distanceY = 0;
      dinoState = DinoState.running;
    } else {
      velY -= GRAVITY_PPSS * elapsedTimeSecond;
    }
  }

  void jump() {
    if (dinoState != DinoState.jumping) {
      dinoState = DinoState.jumping;

      velY = 800;
    }
  }

  void die() {
    currentSprite = _dinoSprites[5];
    dinoState = DinoState.dead;
  }
}
