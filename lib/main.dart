import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:ssi_app/screen/SplashScreen.dart';

void main() {
  runApp(SSIApp());
}

class SSIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSI Blockchain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF0A0E27),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'SF Pro Display',
      ),
      home: SplashScreen(),
    );
  }
}

// Splash Screen với animation
// Login Screen với Glassmorphism
// Create Wallet Screen
// Home Screen with Bottom Navigation
// Dashboard Screen
// Credentials Screen
// Verify Screen
// Profile Screen
