import 'package:dino_game/dino.dart';
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
  final Dino dino = Dino();
  double runDistance = 0;

  late final AnimationController worldController;

  Duration lastUpdateCall = const Duration();

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

    lastUpdateCall = lastElapsedDuration;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final rect = dino.getRect(screenSize, runDistance);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
                animation: worldController,
                builder: (context, child) {
                  return Positioned(
                    top: rect.top,
                    left: rect.left,
                    width: rect.width,
                    height: rect.height,
                    child: dino.render(),
                  );
                })
          ],
        ));
  }
}
