import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    // Animation Curve (اللوجو يكبر تدريجيًا)
    _animation = Tween<double>(begin: 0.5, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // تشغيل الأنيميشن
    _controller.forward();

    // بعد 3 ثواني نروح للهوم
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // مهم
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/images/logo.png',
            width: 180,
            height: 180,
          ),
        ),
      ),
    );
  }
}
