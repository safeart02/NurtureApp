import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/scheduler.dart';
import 'package:testapp10/Startup.dart';
import 'animations.dart';
import 'vegetables.dart';
import 'aboutus.dart';
import 'results.dart';
import 'manual.dart';
import 'Tutorial.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'history.dart';
import 'reminder.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:android_intent_plus/android_intent.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  Sqflite.setDebugModeOn(true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(400, 900),
      builder: (context, child) {
        return MaterialApp(
          title: 'Bluetooth List App',
          theme: ThemeData(
            fontFamily: 'poppins',
            primarySwatch: Colors.green,
          ),
          home: StartingPage(),
        );
      },
    );
  }
}

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  final String targetDeviceName = "HC-05";
  final String targetDeviceAddress = "58:56:00:00:98:E0";
  BluetoothDevice? _connectedDevice;
  double _opacity = 0.0;
  bool _isExpanded = false;

  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _fadeIn();

    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fadeIn() {
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  Future<void> _connectToBluetoothDevice() async {
    final bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (bluetoothState == BluetoothState.STATE_OFF) {
      _showBluetoothSettingsDialog();
      return;
    }

    await _requestPermissions();

    if (await _hasAllRequiredPermissions()) {
      _findAndConnectToDevice();
    } else {
      _showPermissionErrorDialog();
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<bool> _hasAllRequiredPermissions() async {
    return await Permission.bluetoothConnect.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.locationWhenInUse.isGranted;
  }

  void _showBluetoothSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bluetooth Disabled'),
          content:
              Text('Bluetooth is turned off. Please enable it in settings.'),
          actions: [
            TextButton(
              onPressed: () {
                final intent = AndroidIntent(
                  action: 'android.settings.BLUETOOTH_SETTINGS',
                );
                intent.launch();
                Navigator.of(context).pop();
              },
              child: Text('Go to Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _findAndConnectToDevice() async {
    try {
      List<BluetoothDevice> devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      BluetoothDevice? device = devices.firstWhere(
        (d) => d.name == targetDeviceName && d.address == targetDeviceAddress,
        orElse: () => throw Exception('Device not found'),
      );

      setState(() => _connectedDevice = device);
      Navigator.push(
        context,
        BottomToTopTransition(page: ReminderScreen(device: device)),
      );
    } catch (e) {
      _showDeviceErrorDialog();
    }
  }

  void _showDeviceErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Device Not Found'),
        content:
            Text('The Bluetooth device "$targetDeviceName" was not found.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissions Required'),
        content: Text(
            'Please grant the necessary permissions to use the application.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(seconds: 1),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/BG/bg4.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(0.0.w, -0.44.h),
                        child: Container(
                          width: screenWidth * 0.8.w,
                          height: screenHeight * 0.2.h,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/textLOGO.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 315.h,
                        child: Container(
                          width: 300.w,
                          height: 300.h,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 540.h,
                        left: 0.w,
                        right: 0.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 20.h),
                                  Container(
                                    width: 320.w,
                                    height: 150.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/button/getstarted.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: GestureDetector(
                                      onTap: _connectToBluetoothDevice,
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 40.h,
                left: screenWidth * 0.25.w,
                right: screenWidth * 0.25.w,
                child: Container(
                  height: 80.h,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors
                                  .transparent,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    bottom: 150.h,
                                    child: Image.asset(
                                      'assets/images/alert/exit1.png',
                                      width: 350.w,
                                      height: 200.h,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 315.h,
                                    left: 40.w,
                                    child: GestureDetector(
                                      onTap: () => SystemNavigator
                                          .pop(),
                                      child: Image.asset(
                                        'assets/images/alert/yes.png',
                                        width: 100.w,
                                        height: 100.h,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 320.h,
                                    right: 40.w,
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context)
                                          .pop(),
                                      child: Image.asset(
                                        'assets/images/alert/no.png',
                                        width: 100.w,
                                        height: 100.h,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 85.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/button/exit.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 75.h,
                right: 45.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isExpanded) ...[
                      AnimatedOpacity(
                        opacity: _isExpanded ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: AnimatedSlide(
                          offset: _isExpanded ? Offset(0, 0) : Offset(0, 0.2),
                          duration: Duration(milliseconds: 300),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                color: Color(0xFF315853),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 5.h),
                                  child: Text(
                                    'History',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: 10.w),
                              FloatingActionButton(
                                heroTag: 'history',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    RightToLeftTransition(
                                        page: HistoryScreen()),
                                  );
                                },
                                backgroundColor: Color(0xFF315853),
                                child: Icon(Icons.content_paste,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      AnimatedOpacity(
                        opacity: _isExpanded ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: AnimatedSlide(
                          offset: _isExpanded ? Offset(0, 0) : Offset(0, 0.2),
                          duration: Duration(milliseconds: 300),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                color: Color(0xFF315853),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 5.h),
                                  child: Text(
                                    'Manual',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: 10.w),
                              FloatingActionButton(
                                heroTag: 'manual',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    RightToLeftTransition(
                                        page: ManualSelect()),
                                  );
                                },
                                backgroundColor: Color(0xFF315853),
                                child:
                                    Icon(Icons.menu_book, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      AnimatedOpacity(
                        opacity: _isExpanded ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 300),
                        child: AnimatedSlide(
                          offset: _isExpanded ? Offset(0, 0) : Offset(0, 0.2),
                          duration: Duration(milliseconds: 300),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                color: Color(0xFF315853),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 5.h),
                                  child: Text(
                                    'About',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width: 10.w),
                              FloatingActionButton(
                                heroTag: 'about',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    BottomToTopTransition(
                                        page: AboutUs()),
                                  );
                                },
                                backgroundColor: Color(0xFF315853),
                                child: Icon(Icons.info, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(
                        height: 10.h),
                    FloatingActionButton(
                      onPressed: _toggleMenu,
                      backgroundColor: Color(0xFF315853),
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          _isExpanded ? Icons.close : Icons.info,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
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

class VRequirements extends StatelessWidget {
  final String name;
  final Map<String, String> nutrientData;
  final BluetoothDevice device;
  final String image;

  VRequirements({
    required this.name,
    required this.nutrientData,
    required this.device,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG/bg2.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 120),
                painter: ConvexAppBarPainter(),
                child: Container(
                  height: 100,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 16,
                        bottom: 30,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Image.asset(
                            'assets/images/button/back.png',
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '$name Requirements',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 40,
                        child: IconButton(
                          icon: Icon(Icons.help_outline,
                              color: Colors.white, size: 30),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(16.0),
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.6,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Details',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          RichText(
                                            textAlign: TextAlign.justify,
                                            text: TextSpan(
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: 'Nitrogen ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text:
                                                      'is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.',
                                                ),
                                                TextSpan(
                                                  text: '\n\nPhosphorus ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text:
                                                      'improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.',
                                                ),
                                                TextSpan(
                                                  text: '\n\nPotassium ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text:
                                                      'improves the size, quality, and taste of fruits and helps crops resist stress.',
                                                ),
                                                TextSpan(
                                                  text: '\n\nThe pH level ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text:
                                                      'measures soil acidity or alkalinity, ranging from 0 (acidic) to 14 (alkaline), with 7 as neutral. Balanced pH helps plants absorb nutrients efficiently.',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            top: 0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(6.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: image.startsWith('assets/')
                              ? Image.asset(
                                  image,
                                  fit: BoxFit.cover,
                                  height: 300,
                                  width: 300,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image, size: 100);
                                  },
                                )
                              : Image.file(
                                  File(image),
                                  fit: BoxFit.cover,
                                  height: 300,
                                  width: 300,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image, size: 100);
                                  },
                                ),
                        ),
                      ),
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Card(
                      color: Colors.green[800]!,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 300.0,
                          child: Table(
                            border: TableBorder.all(color: Colors.white),
                            children: nutrientData.entries.map((entry) {
                              String range = '';
                              if (entry.value == 'LOW') {
                                range = ' (0-38)';
                              } else if (entry.value == 'MEDIUM') {
                                range = ' (39-128)';
                              } else if (entry.value == 'HIGH') {
                                range = ' (129-255)';
                              }
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      '${entry.value}$range',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          RightToLeftTransition(
                            page: Monitoring(
                              selectedVegetable: name,
                              requiredData: nutrientData,
                              device: device,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/button/analyze.png',
                        width: 250,
                        height: 120,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Monitoring extends StatefulWidget {
  final BluetoothDevice device;
  final String selectedVegetable;
  final Map<String, String> requiredData;

  Monitoring(
      {required this.device,
      required this.selectedVegetable,
      required this.requiredData});

  @override
  _MonitoringState createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring>
    with SingleTickerProviderStateMixin {
  BluetoothConnection? _connection;
  bool _isConnecting = true;
  bool _isConnected = false;
  bool _isScanButtonEnabled = false;
  bool _isScanning = false;
  double _progress = 0;
  bool _shouldImplyLeading = false;

  StringBuffer _buffer = StringBuffer();
  List<String> _receivedData = [];

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    Timer(Duration(seconds: 8), () {
      setState(() {
        _shouldImplyLeading = true;
      });
    });
  }

  void _disposeBluetoothConnection() {
    _connection?.dispose();
    _connection = null;
  }

  void _connectToDevice() async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(widget.device.address);
      setState(() {
        _connection = connection;
        _isConnecting = false;
        _isConnected = true;
        _isScanButtonEnabled = true;
      });

      connection.input!.listen((data) {
        _buffer.write(String.fromCharCodes(data));

        if (_buffer.toString().contains('\n')) {
          List<String> lines = _buffer.toString().split('\n');
          for (int i = 0; i < lines.length - 1; i++) {
            String line = lines[i].trim();
            if (line.isNotEmpty) {
              _receivedData.add(line);
            }
          }
          _buffer.clear();
          _buffer.write(lines.last);

          if (_receivedData.length >= 7) {
            _onDataReceived();
          }
        }
      }).onDone(() {
        setState(() {
          _isConnected = false;
        });
      });
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _receivedData.add('Error: $e');
      });
    }
  }

  void _startScan() {
    if (_isConnected && _connection != null) {
      setState(() {
        _isScanning = true;
        _progress = 0;
      });
      _sendScanCommand();
      _simulateLoading();
    }
  }

  void _sendScanCommand() {
    _connection!.output.add(utf8.encode('1\n'));
    _connection!.output.allSent.then((_) {
      print('Scan command sent.');
    });
  }

  void _simulateLoading() {
    List<int> progressSteps = [
      0,
      3,
      11,
      18,
      23,
      28,
      36,
      47,
      59,
      66,
      78,
      84,
      89,
      93,
      95,
      100,
      100
    ];

    int index = 0;
    Timer? timer;

    void startTimer() {
      timer = Timer.periodic(Duration(milliseconds: 800), (Timer timer) {
        setState(() {
          _progress = progressSteps[index] / 100.0;
        });

        if (index == 11) {
          timer.cancel();

          Future.delayed(Duration(seconds: 3), () {
            index++;
            setState(() {
              _progress = progressSteps[index] / 100.0;
            });
            startTimer();
          });
          return;
        }

        index++;

        if (index >= progressSteps.length) {
          timer.cancel();
          setState(() {
            _progress = 1.0;
          });
          _onDataReceived();
        }
      });
    }

    startTimer();

    Future.delayed(Duration(milliseconds: 800 * progressSteps.length + 3000),
        () {
      if (_progress < 1.0) {
        setState(() {
          _progress = 1.0;
        });
        _onDataReceived();
      }
    });
  }

  void _onDataReceived() {
    if (_receivedData.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please wait...')),
      );
      return;
    }

    if (_progress == 1.0) {
      _navigateToScanComplete();
    }
  }

  void _navigateToScanComplete() {
    setState(() {
      _isScanning = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanCompleteScreen(
          selectedVegetable: widget.selectedVegetable,
          connection: _connection,
          scannedData: {
            'Nitrogen': _receivedData[0],
            'Phosphorus': _receivedData[1],
            'Potassium': _receivedData[2],
            'pH': _receivedData[3],
            'Temperature': _receivedData[4],
            'Moisture': _receivedData[5],
            'ec_val': _receivedData[6],
          },
          requiredData: widget.requiredData,
          device: widget.device,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disposeBluetoothConnection();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _shouldImplyLeading;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/BG/bg2.png',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                CustomPaint(
                  size: Size(
                      MediaQuery.of(context).size.width, 120),
                  painter: ConvexAppBarPainter(),
                  child: Container(
                    height: 100.h,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 16.w,
                          bottom: 30.h,
                          child: IconButton(
                            onPressed: () {
                              if (_shouldImplyLeading) Navigator.pop(context);
                            },
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
                              'Analyzing ${widget.selectedVegetable}',
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
              ],
            ),
            Positioned.fill(
              top: 75.h,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: _isConnecting
                          ? Center(
                              child: LoadingAnimationWidget.hexagonDots(
                                color: Colors.green[800]!,
                                size: 200,
                              ),
                            )
                          : _isConnected
                              ? _isScanning
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: LoadingAnimationWidget
                                              .fourRotatingDots(
                                            color: Colors.green[800]!,
                                            size: 400,
                                          ),
                                        ),
                                        Text(
                                          '${(_progress * 100).toInt()}%',
                                          style: TextStyle(
                                            fontSize: 40.sp,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 83, 59, 50),
                                            fontFamily: 'poorrichards',
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 0.0.h),
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: 500.w,
                                            height: 500.h,
                                            child: Image.asset(
                                              'assets/images/foreground/led.png',
                                              fit: BoxFit.contain,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: InkWell(
                                            onTap: _isScanButtonEnabled
                                                ? _startScan
                                                : null,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20.0.h),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                      'assets/images/button/scan.png',
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                width: 260.w,
                                                height: 100.h,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                              : Text('Disconnected'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RadarAnimation extends StatelessWidget {
  final Animation<double> animation;

  RadarAnimation({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 400 * animation.value,
          height: 400 * animation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withOpacity(1 - animation.value),
          ),
        );
      },
    );
  }
}

class ScanCompleteScreen extends StatelessWidget {
  final String selectedVegetable;
  final Map<String, String> scannedData;
  final Map<String, String> requiredData;
  final BluetoothDevice device;
  final BluetoothConnection? connection;

  ScanCompleteScreen({
    required this.selectedVegetable,
    required this.scannedData,
    required this.requiredData,
    required this.device,
    this.connection,
  });

  Future<void> _sendAndDisposeBluetoothConnection() async {
    if (connection != null && connection!.isConnected) {
      try {
        connection!.output.add(utf8.encode("0"));
        await connection!.output.allSent;

        _disposeBluetoothConnection();
      } catch (e) {
        print("Error sending data or disposing connection: $e");
      }
    }
  }

  void _disposeBluetoothConnection() {
    if (connection != null && connection!.isConnected) {
      connection!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/BG/bg2.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0.h,
              left: 0.w,
              right: 0.w,
              child: CustomPaint(
                size: Size(ScreenUtil().screenWidth,
                    120.h),
                painter: ConvexAppBarPainter(),
                child: Container(
                  height: 100.h,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            'Scan Complete',
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
            ),
            Positioned.fill(
              bottom: 110.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/foreground/scancomplete.png',
                      width: 500.w,
                      height: 500.h,
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () {
                        _sendAndDisposeBluetoothConnection();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Results(
                              selectedVegetable: selectedVegetable,
                              scannedData: scannedData,
                              requiredData: requiredData,
                              device: device,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/button/viewresults.png',
                        width: 250.w,
                        height: 120.h,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
