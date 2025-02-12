import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:testapp10/animations.dart';
import 'package:video_player/video_player.dart';

class ManualSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG/bg7.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 120.w),
                painter: ConvexAppBarPainter(),
                child: Container(
                  height: 100.h,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 16.w,
                        bottom: 30.h,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Image.asset(
                            'assets/images/button/back.png',
                            width: 50.w,
                            height: 50.h,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            'Manual',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              RightToLeftTransition(
                                page: ManualScreen(),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 300.w,
                            height: 330.h,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 8.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12.0.h),
                                    ),
                                    child: Image.asset(
                                      'assets/images/manual/thumb1.png',
                                      fit: BoxFit.contain,
                                      height: 250.h,
                                    ),
                                  ),
                                  SizedBox(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'User Manual: Using the Android Application with HC-05 Hardware',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0.h),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              RightToLeftTransition(
                                page: ManagementScreen(),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 300.w,
                            height: 300.h,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 8.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12.0.h),
                                    ),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      fit: BoxFit.contain,
                                      height: 250.h,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Crop Information Management',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16.0.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ManagementScreen extends StatelessWidget {
  final Map<String, List<Map<String, String>>> categorizedSteps = {
    "Add": [
      {
        'title': 'Step 1: Open the "Add Crop" Screen',
        'description':
            """On the "Select Crop" screen, tap the three-dot menu in the bottom-right corner and choose "Add Crop" from the dropdown.""",
        'video': 'assets/videos/manual/a1_s1.webm',
      },
      {
        'title': 'Step 2: Fill in Crop Details',
        'description':
            """Enter the crop name, description, nutrient levels, and pH. Tap "Pick Image" to select an image and save.""",
        'video': 'assets/videos/manual/a1_s2.webm',
      },
    ],
    "Backup": [
      {
        'title': 'Step 1: Open the Crop Selection Screen',
        'description':
            """On the "Select Crop" screen, tap the three-dot menu in the bottom-right corner and choose "Backup Crops to File" from the dropdown.""",
        'video': 'assets/videos/manual/b1_s1.webm',
      },
      {
        'title': 'Step 2: Enter a File Name',
        'description': """
          -Type a clear and relevant file name (e.g., "Crops").
          -Tap OK to confirm or Cancel to exit.""",
        'video': 'assets/videos/manual/b1_s2.webm',
      },
      {
        'title': 'Step 3: Save the Backup',
        'description':
            """Once confirmed, the crops will be saved to the file, and you'll return to the crop selection screen.""",
        'video': 'assets/videos/manual/b1_s3.webm',
      },
    ],
    "Merge": [
      {
        'title': 'Step 1: Open the Crop Selection Screen',
        'description':
            """On the "Select Crop" screen, tap the three-dot menu in the bottom-right corner and choose "Merge Crops from File".""",
        'video': 'assets/videos/manual/c1_s1.webm',
      },
      {
        'title': 'Step 2: Select a Backup File',
        'description':
            """Tap the desired file from the backup list to merge its crops with the current list.""",
        'video': 'assets/videos/manual/c1_s2.webm',
      },
    ],
    "Archive and Unarchive": [
      {
        'title': 'Archiving Crops',
        'description':
            """Long press a crop on the Select Crop screen to archive it.""",
        'video': 'assets/videos/manual/d1_s1.webm',
      },
      {
        'title': 'Unarchiving Crops',
        'description':
            """Access the Archived Crops screen and long-press a crop to unarchive it.""",
        'video': 'assets/videos/manual/d1_s2.webm',
      },
    ],
  };

  final double cardWidth;
  final double cardHeight;
  final PageController _pageController = PageController();

  ManagementScreen({Key? key, this.cardWidth = 300, this.cardHeight = 400})
      : super(key: key);

  void _playVideoFullscreen(BuildContext context, String videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(videoPath: videoPath),
      ),
    );
  }

  void _showCategoryDetails(
      BuildContext context, String category, List<Map<String, String>> steps) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                ...steps.map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (step['title'] != null)
                            Text(
                              step['title']!,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (step['title'] != null) SizedBox(height: 8.h),
                          if (step['description'] != null)
                            Text(
                              step['description']!,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          SizedBox(height: 10.h),
                          if (step['video'] != null)
                            GestureDetector(
                              onTap: () =>
                                  _playVideoFullscreen(context, step['video']!),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AspectRatio(
                                  aspectRatio: 9 / 20,
                                  child: VideoPlayerWidget(
                                      videoPath: step['video']!),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG/bg7.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 120.w),
                painter: ConvexAppBarPainter(),
                child: Container(
                  height: 100.h,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 16.w,
                        bottom: 30.h,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Image.asset(
                            'assets/images/button/back.png',
                            width: 50.w,
                            height: 50.h,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            'Crop Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: categorizedSteps.keys.length,
                      itemBuilder: (context, categoryIndex) {
                        String category =
                            categorizedSteps.keys.toList()[categoryIndex];
                        List<Map<String, String>> steps =
                            categorizedSteps[category]!;
                        return Align(
                          alignment: Alignment(0.0, -0.8),
                          child: FractionallySizedBox(
                            widthFactor: 0.75,
                            heightFactor: 0.6,
                            child: GestureDetector(
                              onTap: () => _showCategoryDetails(
                                  context, category, steps),
                              child: Card(
                                color: Colors.green[800],
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10.h),
                                      Center(
                                        child: Text(
                                          "Tap to view detailed steps.",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      if (steps[0]['video'] != null)
                                        GestureDetector(
                                          onTap: () => _showCategoryDetails(
                                              context, category, steps),
                                          child: SizedBox(
                                            width: 140.w,
                                            height: 320.h,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: AspectRatio(
                                                aspectRatio: 9 / 20,
                                                child: VideoPlayerWidget(
                                                    videoPath: steps[0]
                                                        ['video']!),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment(0.0, 0.7.h),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: categorizedSteps.keys.length,
                        effect: WormEffect(
                          dotWidth: 20,
                          dotHeight: 20,
                          activeDotColor: Colors.green[800]!,
                          dotColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ],
      ),
    );
  }
}

class ManualScreen extends StatelessWidget {
  final List<Map<String, String>> steps = [
    {
      'title': 'Step 1: Establish Bluetooth Connection.',
      'description':
          """Open the Bluetooth settings on your mobile phone. Turn on your hardware prototype and ensure the red light is on. Pair your device with “HC-05” and enter the code “1234” to establish a connection.""",
      'video': 'assets/videos/manual/v1.webm',
    },
    {
      'title': 'Step 2: Impaling the sensor.',
      'description':
          """Insert the sensor into the soil, ensuring that it is properly submerged and securely in place, so it cannot be moved easily.""",
      'video': 'assets/videos/manual/v2.webm',
    },
    {
      'title': 'Step 3: Open the Application.',
      'description':
          """Launch the Android Application on your mobile phone and tap the “Get Started” button. Ensure the hardware is powered on, and your phone’s Bluetooth is enabled.""",
      'video': 'assets/videos/manual/v3.webm',
    },
    {
      'title': 'Step 4: Select a Crop.',
      'description':
          """Swipe left to view the available crops. Tap on a crop to see its soil nutrient requirements.""",
      'video': 'assets/videos/manual/v4.webm',
    },
    {
      'title': 'Step 5: Start Analyzing the Soil.',
      'description': """
      - Tap the “Analyze” button.  
      - Wait for the green light on the hardware to turn on before tapping “Scan” button and wait until the scanning process is complete.""",
      'video': 'assets/videos/manual/v5.webm',
    },
    {
      'title': 'Step 6: Review Analysis Results and Get Recommendations.',
      'description': """
    Tap the "View Results" button to view a table comparing the soil's current nutrient levels with the selected crop's nutrient requirements.
    Tap the “View Recommendations” button to see suggested commercial and organic fertilizers to improve the soil quality.""",
      'video': 'assets/videos/manual/v6.webm',
    },
    {
      'title': 'Step 7: Saving Report.',
      'description':
          """Tap the save icon to save the scanned results on the history.""",
      'video': 'assets/videos/manual/v7.webm',
    },
  ];

  final double cardWidth;
  final double cardHeight;

  ManualScreen({Key? key, this.cardWidth = 300, this.cardHeight = 400})
      : super(key: key);

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG/bg7.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 120.w),
                painter: ConvexAppBarPainter(),
                child: Container(
                  height: 100.h,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 16.w,
                        bottom: 30.h,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Image.asset(
                            'assets/images/button/back.png',
                            width: 50.w,
                            height: 50.h,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            'Step-by-Step Guide',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.h),
                        Card(
                          color: Colors.green[800],
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: cardWidth.w,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  step['title']!,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  step['description']!,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Card(
                          color: Colors.green[800],
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: GestureDetector(
                            onTap: () =>
                                _playVideoFullscreen(context, step['video']!),
                            child: Container(
                              width: 300.w,
                              height: 220.h,
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: AspectRatio(
                                    aspectRatio: 9 / 20,
                                    child: SizedBox(
                                      width: 100.w,
                                      child: VideoPlayerWidget(
                                        videoPath: step['video']!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 90.h,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: steps.length,
                effect: WormEffect(
                  dotWidth: 20,
                  dotHeight: 20,
                  activeDotColor: Colors.green[800]!,
                  dotColor: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playVideoFullscreen(BuildContext context, String videoPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(videoPath: videoPath),
      ),
    );
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  final String videoPath;

  const FullscreenVideoPlayer({Key? key, required this.videoPath})
      : super(key: key);

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: _controller.value.isInitialized
              ? Column(
                  children: [
                    Flexible(
                      flex: 4,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: [
                          VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Colors.green,
                              backgroundColor: Colors.grey,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.replay_10, color: Colors.white),
                                onPressed: () {
                                  _controller.seekTo(
                                    _controller.value.position -
                                        Duration(seconds: 10),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_controller.value.isPlaying) {
                                      _controller.pause();
                                    } else {
                                      _controller.play();
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.forward_10, color: Colors.white),
                                onPressed: () {
                                  _controller.seekTo(
                                    _controller.value.position +
                                        Duration(seconds: 10),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({Key? key, required this.videoPath})
      : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }
}

class _ZoomableImage extends StatefulWidget {
  final String imagePath;

  _ZoomableImage({required this.imagePath});

  @override
  _ZoomableImageState createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  late TransformationController _transformationController;
  double _currentScale = 1.0;
  final double _minScale = 1.0;
  final double _maxScale = 4.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    setState(() {
      if (_currentScale == _minScale) {
        _currentScale = _maxScale;
        _transformationController.value = Matrix4.identity()..scale(_maxScale);
      } else {
        _currentScale = _minScale;
        _transformationController.value = Matrix4.identity();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        panEnabled: true,
        minScale: _minScale,
        maxScale: _maxScale,
        transformationController: _transformationController,
        child: Image.asset(
          widget.imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class ConvexAppBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green[800]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
