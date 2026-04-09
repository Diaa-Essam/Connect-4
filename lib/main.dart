import 'package:connect_four/presentation/game_screen.dart';
import 'package:flutter/material.dart';
import 'model/board.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: GameScreen());
  }
}
