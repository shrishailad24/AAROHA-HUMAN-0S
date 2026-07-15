import 'package:flutter/material.dart';
import 'features/home/home_screen.dart'; 

void main() {
  runApp(const AAROHAApp());
}

class AAROHAApp extends StatelessWidget {
  const AAROHAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AAROHA Human OS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}