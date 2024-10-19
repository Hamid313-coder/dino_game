import 'dart:math';

import 'package:dino_game/game_objects/cactus.dart';
import 'package:dino_game/game_objects/cloud.dart';
import 'package:dino_game/constants/constants.dart';
import 'package:dino_game/game_objects/dino.dart';
import 'package:dino_game/game_objects/game_object.dart';
import 'package:dino_game/game_objects/ground.dart';
import 'package:dino_game/widgets/restart_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RestartWidget(child: MyApp()));
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
      home: const MyHomePage(title: 'Flutter Dino Game'),
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
  double runVelocity = 55;

  double highScore = 0;
  SharedPreferences? prefs;

  late final ValueNotifier<double> runDistanceNotifier =
      ValueNotifier(runDistance);

  late final AnimationController worldController;

  Duration lastUpdateCall = const Duration();

  final Dino dino = Dino();

  List<Cactus> cacti = [Cactus(worldLocation: const Offset(200, 0))];

  List<Ground> grounds = [
    Ground(worldLocation: const Offset(0, 0)),
    Ground(
        worldLocation:
            Offset(groundSprite.imageWidth / WORLD_TO_PIXEL_RATIO, 0)),
  ];

  List<Cloud> clouds = [
    Cloud(
        worldLocation: Offset(
            Random().nextInt(200) + 100, Random().nextInt(40).toDouble() - 20)),
    Cloud(
        worldLocation: Offset(
            Random().nextInt(200) + 300, Random().nextInt(40).toDouble() - 20)),
    Cloud(
        worldLocation: Offset(
            Random().nextInt(200) + 500, Random().nextInt(40).toDouble() - 20)),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prefs = await SharedPreferences.getInstance();
      highScore = prefs!.getDouble('high_score') ?? 0;
      setState(() {});
    });

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
    runDistanceNotifier.value = runDistance;

    final screenSize = MediaQuery.of(context).size;

    final dinoRect = dino.getRect(screenSize, runDistance).deflate(7);
    for (final cactus in cacti) {
      final obstacleRect = cactus.getRect(screenSize, runDistance);
      if (dinoRect.overlaps(obstacleRect.deflate(7))) _die();

      if (obstacleRect.right < 0) {
        cacti.remove(cactus);
        cacti.add(Cactus(
            worldLocation:
                Offset(runDistance + Random().nextInt(100) + 50, 0)));
        setState(() {});
      }
    }

    for (final ground in grounds) {
      final groundRect = ground.getRect(screenSize, runDistance);
      if (groundRect.right < 0) {
        grounds.remove(ground);
        grounds.add(Ground(
            worldLocation: Offset(
                grounds.last.worldLocation.dx +
                    groundSprite.imageWidth / WORLD_TO_PIXEL_RATIO,
                0)));
        setState(() {});
      }
    }

    for (final cloud in clouds) {
      final cloudRect = cloud.getRect(screenSize, runDistance);
      if (cloudRect.right < 0) {
        clouds.remove(cloud);
        clouds.add(Cloud(
            worldLocation: Offset(
                clouds.last.worldLocation.dx + Random().nextInt(100) + 70,
                Random().nextInt(40) - 20)));
        setState(() {});
      }
    }

    lastUpdateCall = lastElapsedDuration;
  }

  void _die() {
    worldController.stop();
    dino.die();
    final currentScore = runDistance / 10;
    if (currentScore > highScore) {
      highScore = currentScore;
      prefs?.setDouble('high_score', highScore);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    List<GameObject> gameObjects = [...clouds, ...grounds, ...cacti, dino];
    const Duration();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          toolbarHeight: 42,
          actions: [
            Text('High Score: ${highScore.toInt()}'),
            const SizedBox(width: 12),
            ValueListenableBuilder<double>(
                valueListenable: runDistanceNotifier,
                builder: (context, value, _) {
                  return Text('score: ${(runDistance / 10).toInt()}');
                }),
            const SizedBox(width: 4),
          ],
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
                    }),
              if (dino.dinoState == DinoState.dead)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 28,
                    ),
                    child: TextButton(
                      onPressed: () {
                        RestartWidget.restartApp(context);
                      },
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor),
                      child: const Text('Restart'),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }
}
