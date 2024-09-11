import 'dart:math';

import 'package:dino_game/cactus.dart';
import 'package:dino_game/dino.dart';
import 'package:dino_game/game_object.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Dino Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Dino Game Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double runDistance = 0;
  double runVelocity = 50;

  late final AnimationController worldController;

  Duration lastUpdateCall = const Duration();

  final Dino dino = Dino();

  List<Cactus> cacti = [Cactus(worldLocation: const Offset(200, 0))];

  late List<GameObject> gameObjects = [...cacti, dino];

  @override
  void initState() {
    super.initState();
    worldController = AnimationController(
      vsync: this,
      duration: const Duration(days: 100),
    );

    worldController.addListener(_update);

    worldController.forward();
  }

  void _update() {
    final lastElapsedDuration =
        worldController.lastElapsedDuration ?? const Duration();

    dino.update(lastUpdateCall, lastElapsedDuration);

    double elapsedTimeSecond =
        (lastElapsedDuration - lastUpdateCall).inMilliseconds / 1000;

    runDistance += runVelocity * elapsedTimeSecond;

    final screenSize = MediaQuery.of(context).size;

    final dinoRect = dino.getRect(screenSize, runDistance).deflate(7);
    for (final cactus in cacti) {
      final obstacleRect = cactus.getRect(screenSize, runDistance);
      if (dinoRect.overlaps(obstacleRect.deflate(7))) _die();

      if (obstacleRect.right < 0) {
        setState(() {
          cacti.remove(cactus);
          cacti.add(Cactus(
              worldLocation:
                  Offset(runDistance + Random().nextInt(100) + 50, 0)));
          gameObjects = [...cacti, dino];
        });
      }
    }

    lastUpdateCall = lastElapsedDuration;
  }

  void _die() {
    worldController.stop();
    dino.die();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    print('width: ${screenSize.width}');
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: dino.jump,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final object in gameObjects)
                AnimatedBuilder(
                    animation: worldController,
                    builder: (context, child) {
                      final rect = object.getRect(screenSize, runDistance);
                      return Positioned(
                        top: rect.top,
                        left: rect.left,
                        width: rect.width,
                        height: rect.height,
                        child: object.render(),
                      );
                    })
            ],
          ),
        ));
  }
}
