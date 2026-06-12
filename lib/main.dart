import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'screens/calculator_screen.dart';

void main() {
  runApp(const ElectricityBillApp());
}

class ElectricityBillApp extends StatelessWidget {
  const ElectricityBillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '⚡ Bill Estimator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const CalculatorScreen(),
    );
  }
}
