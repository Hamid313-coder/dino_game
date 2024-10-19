import 'package:dino_game/constants/constants.dart';
import 'package:dino_game/game_objects/game_object.dart';
import 'package:dino_game/models/sprite.dart';
import 'package:flutter/material.dart';

final Sprite cloudSprite = Sprite(
  imagePath: 'assets/images/cloud.png',
  imageHeight: 27,
  imageWidth: 92,
);

class Cloud extends GameObject {
  final Offset worldLocation;

  Cloud({required this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * (WORLD_TO_PIXEL_RATIO / 5),
      screenSize.height / 5 - cloudSprite.imageHeight - worldLocation.dy,
      cloudSprite.imageWidth.toDouble(),
      cloudSprite.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(cloudSprite.imagePath);
  }
}
