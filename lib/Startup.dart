import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'main.dart';
import 'Tutorial.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StartingPage extends StatefulWidget {
  @override
  _StartingPageState createState() => _StartingPageState();
}

class _StartingPageState extends State<StartingPage>
    with TickerProviderStateMixin {
  late AnimationController _textController;
  late AnimationController _image1Controller;
  late AnimationController _image2Controller;
  late AnimationController _fingerController;
  late AnimationController _transitionController;

  late Animation<Offset> _textOffsetAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _image1OffsetAnimation;
  late Animation<double> _image1FadeAnimation;
  late Animation<double> _image2FadeAnimation;
  late Animation<double> _fingerScaleAnimation;
  late Animation<double> _transitionScaleAnimation;

  @override
  void initState() {
    super.initState();

    _textController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _textOffsetAnimation =
        Tween<Offset>(begin: Offset(0, .5), end: Offset(0, -2)).animate(
            CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textFadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _image1Controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _image1OffsetAnimation =
        Tween<Offset>(begin: Offset(0, 0.2), end: Offset(0, -0.18)).animate(
            CurvedAnimation(parent: _image1Controller, curve: Curves.easeIn));
    _image1FadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _image1Controller,
      curve: Curves.easeIn,
    ));

    _image2Controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _image2FadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _image2Controller,
      curve: Curves.easeIn,
    ));

    _fingerController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _fingerScaleAnimation =
        Tween<double>(begin: 1.5, end: 1).animate(CurvedAnimation(
      parent: _fingerController,
      curve: Curves.easeInOut,
    ));

    _transitionController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _transitionScaleAnimation =
        Tween<double>(begin: 0, end: 11).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    _startSequentialAnimations();
  }

  void _onTap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    _transitionController.forward().then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => TutorialScreen()),
      );
    });
  }

  void _startSequentialAnimations() {
    _textController.forward().then((_) {
      _image1Controller.forward().then((_) {
        _image2Controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _image1Controller.dispose();
    _image2Controller.dispose();
    _fingerController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: _onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/BG/bg4.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.25,
              child: SlideTransition(
                position: _image1OffsetAnimation,
                child: FadeTransition(
                  opacity: _image1FadeAnimation,
                  child: Image.asset('assets/images/textLOGO.png',
                      width: 320.w, height: 350.h),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.40,
              child: FadeTransition(
                opacity: _image2FadeAnimation,
                child: Image.asset('assets/images/logo.png',
                    width: 300.w, height: 300.h),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.2,
              child: Text(
                "Tap to continue",
                style: TextStyle(fontSize: 20.sp, color: Colors.black),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.1,
              child: ScaleTransition(
                scale: _fingerScaleAnimation,
                child: Icon(Icons.touch_app,
                    size: 50, color: Color.fromARGB(255, 70, 70, 70)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ScaleTransition(
                scale: _transitionScaleAnimation,
                child: ClipOval(
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
