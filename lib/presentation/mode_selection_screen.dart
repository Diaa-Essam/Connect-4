import 'package:flutter/material.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text("Single Player"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Two Players")),
          ],
        ),
      ),
    );
  }
}
