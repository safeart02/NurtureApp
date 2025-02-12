import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final Animation<Offset> _positionAnimation;
  late final Animation<double> _opacityAnimation;

  int _currentPage = 0;
  bool _hasSeenTutorial = false;
  bool _showSwipeHint = true;

  final List<_TutorialCard> tutorialCards = [
    _TutorialCard(image: 'assets/images/manual/a1.jpg', size: const Size(400, 400)),
    _TutorialCard(image: 'assets/images/manual/a2.jpg', size: const Size(400, 400)),
    _TutorialCard(image: 'assets/images/manual/a3.jpg', size: const Size(400, 400)),
    _TutorialCard(image: 'assets/images/manual/a4.jpg', size: const Size(400, 400)),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _setupSwipeHintAnimation();
    _checkIfSeen();
  }

  Future<void> _checkIfSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('hasSeenTutorial') ?? false;

    if (hasSeen) {
      _navigateToHome();
    } else {
      setState(() => _hasSeenTutorial = true);
    }
  }

  Future<void> _markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenTutorial', true);
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainMenu()),
    );
  }

  void _setupSwipeHintAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _positionAnimation = Tween<Offset>(
      begin: const Offset(-0.6, 0),
      end: const Offset(0.6, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      if (_showSwipeHint && index > 0) {
        _showSwipeHint = false;
        _animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _skipTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Tutorial'),
        content: const Text('Are you sure you want to skip the tutorial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await _markAsSeen();
              Navigator.of(context).pop();
              _navigateToHome();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  if (!_hasSeenTutorial) {
    return const SizedBox.shrink();
  }

  return Scaffold(
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/BG/bg4.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 500.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: tutorialCards.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => Center(child: tutorialCards[index]),
            ),
          ),
        ),
        Positioned(
          bottom: 20.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(tutorialCards.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: _currentPage == index ? 12.w : 8.w,
                height: _currentPage == index ? 12.h : 8.h,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color.fromARGB(255, 240, 240, 240)
                      : const Color.fromARGB(255, 20, 80, 33),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
        if (_showSwipeHint && _currentPage == 0)
          Positioned(
            bottom: 80.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text('Swipe left to continue', style: TextStyle(color: Colors.black)),
                const SizedBox(height: 8),
                SlideTransition(
                  position: _positionAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: const Icon(Icons.touch_app, color: Color.fromARGB(255, 20, 80, 33), size: 36),
                  ),
                ),
              ],
            ),
          ),
        if (_currentPage < tutorialCards.length - 1)
          Positioned(
            bottom: 200.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _skipTutorial,
                child: Image.asset(
                  'assets/images/button/skip.png',
                  width: 120.w,
                ),
              ),
            ),
          ),
        if (_currentPage == tutorialCards.length - 1)
          Positioned(
            bottom: 200.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  await _markAsSeen();
                  _navigateToHome();
                },
                child: Image.asset(
                  'assets/images/button/proceed_tutorial.png',
                  width: 120.w,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
}

class _TutorialCard extends StatelessWidget {
  final String image;
  final Size size;

  const _TutorialCard({required this.image, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      width: size.width,
      height: size.height,
      fit: BoxFit.contain,
    );
  }
}
