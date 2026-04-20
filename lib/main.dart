import 'package:connect_four/presentation/game_screen.dart';
import 'package:connect_four/presentation/mode_selection_screen.dart';
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
      home: ModeSelectionScreen(),
    );
  }
}
