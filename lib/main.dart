import 'package:flutter/material.dart';
import 'screens/citizen/splash_screen.dart';

void main() {
  runApp(const AirPulseAI());
}

class AirPulseAI extends StatelessWidget {
  const AirPulseAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AirPulse AI',
      home: const SplashScreen(),
    );
  }
}