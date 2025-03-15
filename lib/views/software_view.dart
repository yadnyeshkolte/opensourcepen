import 'package:flutter/material.dart';

class SoftwareView extends StatelessWidget {
  const SoftwareView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Software')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Software Version: 1.0.0', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Build: 2025.03.15', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Release Channel: Stable', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}