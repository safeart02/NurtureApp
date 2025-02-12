import 'dart:ffi' as ffi;
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'vegetables.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConvexAppBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green[800]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class Results extends StatelessWidget {
  final String selectedVegetable;
  final Map<String, String> scannedData;
  final Map<String, String> requiredData;
  final BluetoothDevice device;
  final ScreenshotController screenshotController = ScreenshotController();

  Results({
    required this.selectedVegetable,
    required this.scannedData,
    required this.requiredData,
    required this.device,
  });

  double mapPHValue(double? scannedPH) {
    if (scannedPH == null) return 1.0;
    return (scannedPH * (13 / 25));
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: WillPopScope(
        onWillPop: () async => false,
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
                  size: Size(MediaQuery.of(context).size.width, 120.w),
                  painter: ConvexAppBarPainter(),
                  child: Container(
                    height: 100.h,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              '${selectedVegetable.toUpperCase()} RESULT',
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
                top: 100.h,
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNutrientCard(),
                              _buildAdditionalInfo(),
                              _buildRecommendationButton(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0.h,
                left: 0.w,
                right: 0.w,
                child: BottomFloatingCustomBars(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showNameDialog(BuildContext context, String selectedVegetable,
      Map<String, String> scannedData) async {
    TextEditingController labelController = TextEditingController();

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Record Name'),
          content: TextField(
            controller: labelController,
            decoration:
                InputDecoration(hintText: 'Enter a name for this record'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String label = labelController.text.trim();

                if (label.isNotEmpty) {
                  await _saveHistory(selectedVegetable, scannedData, label);

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Results have been stored to history.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a label.')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaveHistoryButton(BuildContext context, String selectedVegetable,
      Map<String, String> scannedData) {
    return Positioned(
      bottom: 16.0.h,
      left: 16.0.w,
      child: InkWell(
        onTap: () async {
          await _showNameDialog(context, selectedVegetable, scannedData);
        },
        child: Container(
          width: 60.0.w,
          height: 60.0.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors
                .green,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Icon(
            Icons.history,
            color: Colors.white,
            size: 30.0,
          ),
        ),
      ),
    );
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    print('Database Path: $databasePath');
    return openDatabase(
      join(databasePath, 'plants.db'),
      version: 1,
      onCreate: (db, version) async {
        print('Creating database...');
        await db.execute('''
        CREATE TABLE history (
          historyID INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          scannedData TEXT NOT NULL,
          label TEXT NOT NULL
        )
      ''');
      },
      onOpen: (db) async {
        print('Database opened...');
        await db.execute('''
        CREATE TABLE IF NOT EXISTS history (
          historyID INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          scannedData TEXT NOT NULL,
          label TEXT NOT NULL
        )
      ''');
      },
    );
  }

  Widget BottomFloatingCustomBars(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 0.0.h),
      margin: EdgeInsets.only(bottom: 16.0.h, left: 16.0.w, right: 16.0.w),
      decoration: BoxDecoration(
        color: Color.fromARGB(181, 46, 125, 50),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              _showNameDialog(context, selectedVegetable, scannedData);
            },
            icon: Image.asset(
              'assets/images/button/save.png',
              width: 40.0.w,
              height: 40.0.h,
            ),
          ),

          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors
                      .transparent,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        bottom: 150.h,
                        child: Image.asset(
                          'assets/images/alert/mainmenu.png',
                          width: 350.w,
                          height: 200.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        bottom: 315.h,
                        left: 40.w,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainMenu()),
                              (route) => false,
                            );
                          },
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
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            'assets/images/alert/no.png',
                            width: 100.w,
                            height: 100.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            icon: Image.asset(
              'assets/images/button/home.png',
              width: 60.0.w,
              height: 60.0.h,
            ),
          ),

          IconButton(
            onPressed: () async {
              _captureAndSaveScreenshot(context);
            },
            icon: Image.asset(
              'assets/images/button/screenshot.png',
              width: 45.0.w,
              height: 45.0.h,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndSaveScreenshot(BuildContext context) async {
    try {
      final Uint8List? screenshot = await screenshotController.capture();
      if (screenshot != null) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/results.png';
        final file = File(filePath);

        await file.writeAsBytes(screenshot);

        await GallerySaver.saveImage(filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot saved to gallery as results.png')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save screenshot: $e')),
      );
    }
  }

  Future<void> _saveHistory(String selectedVegetable,
      Map<String, String> scannedData, String label) async {
    try {
      final db = await _initDatabase();

      final timestamp = DateTime.now().toIso8601String();

      final scannedDataJson = jsonEncode(scannedData);

      await db.insert(
        'history',
        {
          'name': selectedVegetable,
          'timestamp': timestamp,
          'scannedData': scannedDataJson,
          'label': label,
        },
      );

      print('Data successfully saved to the history table.');
    } catch (e) {
      print(
          'Error saving data to the history table: $e, please avoid using the same names.');
    }
  }

  Widget _buildScreenshotButton(BuildContext context) {
    return Positioned(
      bottom: 16.0.h,
      right: 16.0.w,
      child: InkWell(
        onTap: () => _captureAndSaveScreenshot(context),
        child: Container(
          width: 60.0.w,
          height: 60.0.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Icon(
            Icons.screenshot,
            color: Colors.white,
            size: 30.0,
          ),
        ),
      ),
    );
  }

  Card _buildNutrientCard({
    double width = double.infinity,
    double height = 255.0,
    double cardMargin = 20.0,
    double tableWidth = 10,
    double tableHeight = 10,
  }) {
    return Card(
      color: Colors.green[800]!,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.all(cardMargin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            15.0),
        child: Container(
          width: width.w,
          height: height.h,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              width: tableWidth.w,
              height: tableHeight.h,
              child: Table(
                columnWidths: {
                  0: FixedColumnWidth(tableWidth.w / 3),
                  1: FixedColumnWidth(tableWidth.w / 3),
                  2: FixedColumnWidth(tableWidth.w / 3),
                },
                border: TableBorder.all(
                    color: Colors.white),
                children: [
                  buildRow('Nutrient', 'Required', 'Scanned', isHeader: true),
                  buildRow(
                    'Nitrogen',
                    formatNutrientLevel(requiredData['Nitrogen'] ?? 'N/A'),
                    categorizeNutrient(scannedData['Nitrogen']),
                  ),
                  buildRow(
                    'Phosphorus',
                    formatNutrientLevel(requiredData['Phosphorus'] ?? 'N/A'),
                    categorizeNutrient(scannedData['Phosphorus']),
                  ),
                  buildRow(
                    'Potassium',
                    formatNutrientLevel(requiredData['Potassium'] ?? 'N/A'),
                    categorizeNutrient(scannedData['Potassium']),
                  ),
                  buildRow(
                    'pH',
                    requiredData['pH'] ?? 'N/A',
                    (mapPHValue(double.tryParse(scannedData['pH'] ?? '')))
                        .toStringAsFixed(1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatNutrientLevel(String level) {
  if (level == 'HIGH') {
    return 'HIGH (129-255) mg/kg';
  } else if (level == 'MEDIUM') {
    return 'MEDIUM (39-128) mg/kg';
  } else if (level == 'LOW') {
    return 'LOW (0-38) mg/kg';
  } else {
    return level;
  }
}

  Padding _buildAdditionalInfo() {
    return Padding(
      padding: EdgeInsets.only(
        top: 16.0.h,
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              'Additional Information',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            color: Colors.green[800]!,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 320.w,
                height: 40.0.h,
                alignment:
                    Alignment.center,
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(160.w),
                    1: FixedColumnWidth(160.w),
                  },
                  border: TableBorder.all(color: Colors.white),
                  children: [
                    buildInfoRow('Moisture',
                        categorizeMoisture(scannedData['Moisture'])),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String categorizeMoisture(String? value) {
    if (value == null || value.isEmpty) return 'Unknown';
    try {
      double doubleValue = double.parse(value);
      if (doubleValue < 0 || doubleValue > 25.5) return 'Out of Range';

      if (doubleValue < 8.5) {
        return 'Dry';
      } else if (doubleValue < 17.0) {
        return 'Normal';
      } else {
        return 'Wet';
      }
    } catch (e) {
      return 'Invalid Value';
    }
  }

  Center _buildRecommendationButton(BuildContext context,
      {double width = 250.0, double height = 110.0}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 16.0.h),
        child: GestureDetector(
          onTap: () {
            _showRecommendation(
                context);
          },
          child: Container(
            width: width.w,
            height: height.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/button/recommendation.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      width: 65.0.w,
      height: 65.0.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.w),
      ),
      child: Material(
        shape: CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Confirm Navigation'),
                  content: Text('Do you want to go back to Crop Selection?'),
                  actions: [
                    TextButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Yes'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VSelect(device: device),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Icon(
            Icons.home,
            color: Colors.white,
          ),
          backgroundColor: Colors.green[800],
          tooltip: 'Go to Crop Selection',
        ),
      ),
    );
  }

  String categorizeNutrient(String? value) {
  if (value == null || value.isEmpty) {
    return 'Unknown';
  }
  try {
    int intValue = int.parse(value);

    double computedValue = (intValue * 1999) / 255;
    String computedString = intValue.toStringAsFixed(0);

    if (computedValue >= 0 && computedValue <= 299) {
      return 'LOW ($computedString) mg/kg\n';
    } else if (computedValue >= 300 && computedValue <= 1000) {
      return 'MEDIUM ($computedString) mg/kg\n';
    } else if (computedValue > 1000 && computedValue <= 1999) {
      return 'HIGH ($computedString) mg/kg\n';
    } else {
      return 'Value is out of bounds ($computedString).';
    }
  } catch (e) {
    return 'Invalid input.';
  }
}

  Color determineCellColor(String required, String scanned) {
  String extractCategory(String input) {
    return input.split(' ').first.toUpperCase();
  }

  String requiredCategory = extractCategory(required);
  String scannedCategory = extractCategory(scanned);

  if (requiredCategory == "HIGH") {
    if (scannedCategory == "HIGH") return Color(0xFF93C47D);
    if (scannedCategory == "MEDIUM") return Color(0xFFFFE599);
    if (scannedCategory == "LOW") return Color(0xFFEA9999);
  } else if (requiredCategory == "MEDIUM") {
    if (scannedCategory == "MEDIUM") return Color(0xFF93C47D);
    if (scannedCategory == "HIGH" || scannedCategory == "LOW") return Color(0xFFEA9999);
  } else if (requiredCategory == "LOW") {
    if (scannedCategory == "MEDIUM" || scannedCategory == "HIGH") return Color(0xFFEA9999);
    if (scannedCategory == "LOW") return Color(0xFF93C47D);
  }
  return Colors.transparent; // Default color for unmatched conditions
}

  Color determinePHColor(double? phValue) {
    if (phValue == null || phValue < 0 || phValue > 14) {
      return Colors.grey;
    }
    if (phValue >= 0 && phValue < 1) return Colors.red[900]!;
    if (phValue >= 1 && phValue < 3) return Colors.red;
    if (phValue >= 3 && phValue < 5) return Colors.orange;
    if (phValue >= 5 && phValue < 6.5) return Colors.yellow;
    if (phValue >= 6.5 && phValue <= 7.5) return Colors.green;
    if (phValue > 7.5 && phValue <= 9) return Colors.cyan;
    if (phValue > 9 && phValue <= 11) return Colors.blue;
    if (phValue > 11 && phValue <= 14) return Colors.indigo;
    return Colors.grey;
  }

  TableRow buildRow(String nutrient, String required, String scanned,
      {bool isHeader = false}) {
    return TableRow(
      children: [
        Container(
          color: isHeader
              ? Color.fromARGB(255, 25, 65, 33)
              : Colors.transparent,
          padding: EdgeInsets.all(8.0),
          child: Text(
            nutrient,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
                fontSize: 12.sp),
          ),
        ),
        Container(
          color: isHeader
              ? Color.fromARGB(255, 25, 65, 33)
              : Colors.transparent,
          padding: EdgeInsets.all(8.0),
          child: Text(
            required,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
                fontSize: 12.sp),
          ),
        ),
        Container(
          color: nutrient == "pH" && !isHeader
              ? determinePHColor(
                  double.tryParse(scanned) ?? -1)
              : isHeader
                  ? Color.fromARGB(255, 25, 65, 33)
                  : determineCellColor(
                      required, scanned),
          padding: EdgeInsets.all(8.0),
          child: Text(
            scanned,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
                fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  TableRow buildInfoRow(String label, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label, style: (TextStyle(color: Colors.white))),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value ?? 'N/A', style: (TextStyle(color: Colors.white))),
        ),
      ],
    );
  }

  void _showRecommendation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final String recommendation = _generateRecommendation();

        return Container(
          height: MediaQuery.of(context).size.height *
              0.8,
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/images/BG/bg5.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommendation',
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10.h),
                      ..._buildRecommendationWidgets(
                        recommendation.isNotEmpty
                            ? recommendation
                            : 'Apply an ample amount of 14-14-14 or Triple 14 Complete Fertilizer (Harvester) to the lot area intended for planting. It provides a balanced mix of essential nutrients with equal proportions of nitrogen, phosphorus, and potassium.',
                        context,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Recommended Organic Fertilizer\n',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Here are some recommendations for organic fertilization:\n\n'
                        '• Vermicompost – Improves NPK content and enhances pH level.\n\n'
                        '• Poultry Manure – Boosts NPK levels and pH balance.\n\n'
                        '• Eggshells – Primarily improves soil pH, also contributes to NPK.\n\n'
                        '• Wood Ash – Great source of phosphorus and potassium.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildRecommendationWidgets(
      String recommendations, BuildContext context) {
    List<String> lines = recommendations.split('\n');
    return lines.map((line) {
      if (line.startsWith('') && line.contains(':')) {
        int endIndex = line.indexOf(':', 2);
        String boldText = line.substring(2, endIndex);
        String remainingText = line.substring(endIndex + 3);

        return RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: boldText + ': ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: remainingText),
            ],
          ),
        );
      } else {
        return Text(line);
      }
    }).toList();
  }

  String _generateRecommendation() {
    if (selectedVegetable == null) {
      return 'Please select a vegetable to see recommendations.';
    }

    List<String> recommendations = [];
    switch (selectedVegetable) {
      case 'Okra':
        recommendations.addAll(_generateOkraRecommendations());
        break;
      case 'Talong':
        recommendations.addAll(_generateTalongRecommendations());
        break;
      case 'Banana':
        recommendations.addAll(_generateBananaRecommendations());
        break;
      case 'Sweet Potato':
        recommendations.addAll(_generateSweetPotatoRecommendations());
        break;
      case 'Cucumber':
        recommendations.addAll(_generateCucumberRecommendations());
        break;
      default:
        recommendations.add(
            'No specific commercial fertilizer available for $selectedVegetable.');
        break;
    }
    return recommendations.isNotEmpty
        ? recommendations.join('\n')
        : 'No recommendations generated.';
  }

  List<String> _generateOkraRecommendations() {
    List<String> recommendations = [];

    String nitrogenLevel = categorizeNutrient(scannedData['Nitrogen']);

    String extractCategory(String input) {
    return input.split(' ').first.toUpperCase();
  }

  String scannedCategoryN = extractCategory(nitrogenLevel);
    
    if (scannedCategoryN == 'LOW') {
      recommendations.add(
          'NITROGEN\nApply 5.2-6.7 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    } else if (scannedCategoryN== 'MEDIUM') {
      recommendations.add(
          'NITROGEN\nApply 2.1-5.2 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    } else if (scannedCategoryN == 'HIGH') {
      recommendations.add(
          'NITROGEN\nApply 0 - 2.1 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    }

    String phosphorusLevel = categorizeNutrient(scannedData['Phosphorus']);
    String scannedCategoryP = extractCategory(phosphorusLevel);

    if (scannedCategoryP == 'LOW') {
      recommendations.add(
          'PHOSPHORUS\nApply 6.1-7.8 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    } else if (scannedCategoryP == 'MEDIUM') {
      recommendations.add(
          'PHOSPHORUS\nApply 2.5-6.1 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    } else if (scannedCategoryP == 'HIGH') {
      recommendations.add(
          'PHOSPHORUS\nApply 0-2.5 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    }

    String potassiumLevel = categorizeNutrient(scannedData['Potassium']);
    String scannedCategoryK = extractCategory(potassiumLevel);

    if (scannedCategoryK == 'LOW') {
      recommendations.add(
          'POTASSIUM\nApply 0.8-1.8 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    } else if (scannedCategoryK == 'MEDIUM') {
      recommendations.add(
          'POTASSIUM\nApply 0.8-1.8 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    } else if (scannedCategoryK == 'HIGH') {
      recommendations.add(
          'POTASSIUM\nApply 0.8-1.8 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    }

    return recommendations;
  }

  List<String> _generateTalongRecommendations() {
    List<String> recommendations = [];

    String extractCategory(String input) {
    return input.split(' ').first.toUpperCase();
  }

    String nitrogenLevel = categorizeNutrient(scannedData['Nitrogen']);
    String scannedCategoryN = extractCategory(nitrogenLevel);

    if (scannedCategoryN == 'LOW') {
      recommendations.add(
          'NITROGEN\nApply 14.3-29 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    } else if (scannedCategoryN == 'MEDIUM') {
      recommendations.add(
          'NITROGEN\nApply 7.1-14.3 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    } else if (scannedCategoryN == 'HIGH') {
      recommendations.add(
          'NITROGEN\nApply 0-7.1 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    }

    String phosphorusLevel = categorizeNutrient(scannedData['Phosphorus']);
    String scannedCategoryP = extractCategory(phosphorusLevel);

    if (scannedCategoryP == 'LOW') {
      recommendations.add(
          'PHOSPHORUS\nApply 16.7-36.1 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    } else if (scannedCategoryP == 'MEDIUM') {
      recommendations.add(
          'PHOSPHORUS\nApply 5.6-16.7 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    } else if (scannedCategoryP == 'HIGH') {
      recommendations.add(
          'PHOSPHORUS\nApply 0-5.1 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    }

    String potassiumLevel = categorizeNutrient(scannedData['Potassium']);
    String scannedCategoryK = extractCategory(potassiumLevel);
    if (scannedCategoryK == 'LOW') {
      recommendations.add(
          'POTASSIUM\nApply 2.5 – 8.0 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    } else if (scannedCategoryK == 'MEDIUM') {
      recommendations.add(
          'POTASSIUM\nApply 2.5 – 8.0 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    } else if (scannedCategoryK == 'HIGH') {
      recommendations.add(
          'POTASSIUM\nApply 2.5 – 8.0 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    }

    return recommendations;
  }

  List<String> _generateBananaRecommendations() {
    List<String> recommendations = [];

    String extractCategory(String input) {
    return input.split(' ').first.toUpperCase();
  }

    String nitrogenLevel = categorizeNutrient(scannedData['Nitrogen']);
    String scannedCategoryN = extractCategory(nitrogenLevel);
    if (scannedCategoryN == 'LOW') {
      recommendations.add(
          'NITROGEN\nApply 357-762 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    } else if (scannedCategoryN == 'MEDIUM') {
      recommendations.add(
          'NITROGEN\nApply 190-357 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    } else if (scannedCategoryN == 'HIGH') {
      recommendations.add(
          'NITROGEN\nApply 0-190 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    }

    String phosphorusLevel = categorizeNutrient(scannedData['Phosphorus']);
    String scannedCategoryP = extractCategory(phosphorusLevel);
    if (scannedCategoryP == 'LOW') {
      recommendations.add(
          'PHOSPHORUS\nApply 278-333 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    } else if (scannedCategoryP == 'MEDIUM') {
      recommendations.add(
          'PHOSPHORUS\nApply 111-278 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    } else if (scannedCategoryP == 'HIGH') {
      recommendations.add(
          'PHOSPHORUS\nApply 0-111 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    }

    String potassiumLevel = categorizeNutrient(scannedData['Potassium']);
    String scannedCategoryK = extractCategory(potassiumLevel);
    if (scannedCategoryK == 'LOW') {
      recommendations.add(
          'POTASSIUM\nApply 83-333 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    } else if (scannedCategoryK == 'MEDIUM') {
      recommendations.add(
          'POTASSIUM\nApply 83-333 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    } else if (scannedCategoryK == 'HIGH') {
      recommendations.add(
          'POTASSIUM\nApply 83-333 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    }

    return recommendations;
  }

  List<String> _generateSweetPotatoRecommendations() {
    List<String> recommendations = [];

    String extractCategory(String input) {
    return input.split(' ').first.toUpperCase();
  }

    String nitrogenLevel = categorizeNutrient(scannedData['Nitrogen']);
    String scannedCategoryN= extractCategory(nitrogenLevel);
    if (scannedCategoryN == 'LOW') {
      recommendations.add(
          'NITROGEN\nApply 8.1-16 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    } else if (scannedCategoryN == 'MEDIUM') {
      recommendations.add(
          'NITROGEN\nApply 3.3-8.1 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    } else if (scannedCategoryN == 'HIGH') {
      recommendations.add(
          'NITROGEN\nApply 0-3.3 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    }

    String phosphorusLevel = categorizeNutrient(scannedData['Phosphorus']);
    String scannedCategoryP = extractCategory(phosphorusLevel);
    if (scannedCategoryP == 'LOW') {
      recommendations.add(
          'PHOSPHORUS\nApply 9.4-18.9 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    } else if (scannedCategoryP == 'MEDIUM') {
      recommendations.add(
          'PHOSPHORUS\nApply 3.9-9.4 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    } else if (scannedCategoryP == 'HIGH') {
      recommendations.add(
          'PHOSPHORUS\nApply 0-3.9 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    }

    String potassiumLevel = categorizeNutrient(scannedData['Potassium']);
    String scannedCategoryK = extractCategory(potassiumLevel);
    if (scannedCategoryK == 'LOW') {
      recommendations.add(
          'POTASSIUM\nApply 1.8 – 5.7 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    } else if (scannedCategoryK == 'MEDIUM') {
      recommendations.add(
          'POTASSIUM\nApply 1.8 – 5.7 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    } else if (scannedCategoryK == 'HIGH') {
      recommendations.add(
          'POTASSIUM\nApply 1.8 – 5.7 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    }

    return recommendations;
  }

  List<String> _generateCucumberRecommendations() {
    List<String> recommendations = [];

    String extractCategory(String input) {
    return input.split(' ').first.toUpperCase();
  }

    String nitrogenLevel = categorizeNutrient(scannedData['Nitrogen']);
    String scannedCategoryN = extractCategory(nitrogenLevel);
    if (scannedCategoryN == 'LOW') {
      recommendations.add(
          'NITROGEN\nApply 7.6 - 12 grams of 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    } else if (scannedCategoryN == 'MEDIUM') {
      recommendations.add(
          'NITROGEN\nApply 2.8 - 9.0 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    } else if (scannedCategoryN == 'HIGH') {
      recommendations.add(
          'NITROGEN\nApply 0-3.8 grams of 21% Ammonium Sulfate or 21-00 fertilizer per plant. Nitrogen is important for photosynthesis, helping crops grow better and produce higher yields. It also makes leaves healthy and green.\n');
    }

    String phosphorusLevel = categorizeNutrient(scannedData['Phosphorus']);
    String scannedCategoryP = extractCategory(phosphorusLevel);
    if (scannedCategoryP == 'LOW') {
      recommendations.add(
          'PHOSPHORUS\nApply 8.9 - 21.1 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    } else if (scannedCategoryP == 'MEDIUM') {
      recommendations.add(
          'PHOSPHORUS\nApply 3.9 - 8.9 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    } else if (scannedCategoryP == 'HIGH') {
      recommendations.add(
          'PHOSPHORUS\nApply 0-3.9 grams of 18% superphosphate fertilizer per plant. Phosphorus improves stem strength, boosts root growth, and enhances flowers and seeds. It also supports early growth and increases crop yield.\n');
    }

    String potassiumLevel = categorizeNutrient(scannedData['Potassium']);
    String scannedCategoryK = extractCategory(potassiumLevel);
    if (scannedCategoryK == 'LOW') {
      recommendations.add(
          'POTASSIUM\nApply 1.2 – 3.4 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    } else if (scannedCategoryK == 'MEDIUM') {
      recommendations.add(
          'POTASSIUM\nApply 1.2 – 3.4 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    } else if (scannedCategoryK == 'HIGH') {
      recommendations.add(
          'POTASSIUM\nApply 1.2 – 3.4 grams of Potassium Chloride or Muriate Potash fertilizer per plant. Potassium improves the size, quality, and taste of fruits and helps crops resist stress.\n');
    }

    return recommendations;
  }

  bool _checkNutrient(String nutrient) {
    String? scannedValue = scannedData[nutrient];
    String? requiredValue = requiredData[nutrient];

    if (scannedValue == null || requiredValue == null) {
      return false;
    }
    try {
      return int.parse(scannedValue) < int.parse(requiredValue);
    } catch (e) {
      return false;
    }
  }
}
