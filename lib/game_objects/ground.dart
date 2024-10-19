import 'package:dino_game/constants/constants.dart';
import 'package:dino_game/game_objects/game_object.dart';
import 'package:dino_game/models/sprite.dart';
import 'package:flutter/material.dart';

final Sprite groundSprite = Sprite(
  imagePath: 'assets/images/ground.png',
  imageHeight: 24,
  imageWidth: 2399,
);

class Ground extends GameObject {
  final Offset worldLocation;

  Ground({required this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * WORLD_TO_PIXEL_RATIO,
      screenSize.height / 2 - groundSprite.imageHeight,
      groundSprite.imageWidth.toDouble(),
      groundSprite.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(groundSprite.imagePath);
  }
}
