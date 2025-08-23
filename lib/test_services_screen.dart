import 'package:flutter/material.dart';
import 'features/services/presentation/screens/services_screen.dart';

void main() {
  runApp(const TestServicesApp());
}

class TestServicesApp extends StatelessWidget {
  const TestServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Services Screen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const ServicesScreen(),
    );
  }
}