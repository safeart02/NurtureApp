import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();

  DatabaseHelper._();

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

  Future<int> updateLabel(int historyID, String newLabel) async {
    final db = await database;
    return await db.update(
      'history',
      {'label': newLabel},
      where: 'historyID = ?',
      whereArgs: [historyID],
    );
  }

  Future<Database> get database async {
    return await _initDatabase();
  }

  Future<List<Map<String, dynamic>>> getAllCrops() async {
    final db = await database;
    return await db.rawQuery('SELECT DISTINCT name FROM history');
  }

  Future<List<Map<String, dynamic>>> getHistoryByCrop(String cropName) async {
    final db = await database;
    return await db.query(
      'history',
      where: 'name = ?',
      whereArgs: [cropName],
      orderBy: 'timestamp DESC',
    );
  }

  Future<Map<String, dynamic>> getHistoryDetails(int historyID) async {
    final db = await database;
    final results = await db.query(
      'history',
      where: 'historyID = ?',
      whereArgs: [historyID],
    );
    return results.isNotEmpty ? results.first : {};
  }
}

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG/bg6.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 120.h),
                painter: ConvexAppBarPainter(),
                child: Container(
                    height: 100.h,
                    child: CustomPaint(
                      size: Size(MediaQuery.of(context).size.width, 120.h),
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
                                  width: 50.h,
                                  height: 50.h,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Text(
                                  'History',
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
                    )),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper.instance.getAllCrops(),
                  builder: (context, snapshot) {
                    print(
                        'Snapshot: ${snapshot.connectionState}, Data: ${snapshot.data}');
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No crops found.'));
                    }
                    final crops = snapshot.data!;
                    return ListView.builder(
                      itemCount: crops.length,
                      itemBuilder: (context, index) {
                        final crop = crops[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0.w, vertical: 8.0.h),
                          child: Card(
                            elevation: 8,
                            color: Color.fromARGB(255, 170, 212, 158),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                crop['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CropHistoryScreen(cropName: crop['name']),
                                ),
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
        ],
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

class CropHistoryScreen extends StatefulWidget {
  final String cropName;

  CropHistoryScreen({required this.cropName});

  @override
  _CropHistoryScreenState createState() => _CropHistoryScreenState();
}

class _CropHistoryScreenState extends State<CropHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = DatabaseHelper.instance.getHistoryByCrop(widget.cropName);
  }

  Future<void> _updateLabel(BuildContext context, int historyID) async {
    TextEditingController labelController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Label'),
        content: TextField(
          controller: labelController,
          decoration: InputDecoration(
            labelText: 'New Label',
            hintText: 'Enter new label',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newLabel = labelController.text;
              if (newLabel.isNotEmpty) {
                await DatabaseHelper.instance.updateLabel(historyID, newLabel);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Label updated successfully')),
                );

                setState(() {
                  _loadHistory();
                });
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG/bg6.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              CustomPaint(
                size: Size(
                    MediaQuery.of(context).size.width, 120.h),
                painter: ConvexAppBarPainter(),
                child: Container(
                  height: 100.h,
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width,
                        120.h),
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
                                width: 50.h,
                                height: 50.h,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                'History',
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
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final history = snapshot.data!;
                    if (history.isEmpty) {
                      return Center(
                        child: Text(
                          'No history available for ${widget.cropName}',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0.w, vertical: 8.0.h),
                          child: Card(
                            elevation: 8,
                            color: Color.fromARGB(255, 170, 212, 158),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                entry['label'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HistoryDetailsScreen(
                                      historyID: entry['historyID']),
                                ),
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
        ],
      ),
    );
  }
}

class HistoryDetailsScreen extends StatelessWidget {
  final int historyID;

  HistoryDetailsScreen({required this.historyID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG/bg6.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 120.h),
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
                            width: 50.h,
                            height: 50.h,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            'Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16.h,
                        bottom: 44.h,
                        child: IconButton(
                          icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                          onPressed: () async {
                            final entry = await DatabaseHelper.instance
                                .getHistoryDetails(historyID);
                            final scannedData = _normalizeScannedData(
                              jsonDecode(entry['scannedData']),
                            );
                            await _generateAndSharePDF(entry, scannedData);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: DatabaseHelper.instance.getHistoryDetails(historyID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'An error occurred. Please try again.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'No data found.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    final entry = snapshot.data!;
                    final scannedData = _normalizeScannedData(
                      jsonDecode(entry['scannedData'] ?? '{}'),
                    );

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(30.0),
                      child: Card(
                        color: Colors.green[800]!,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Crop: ${entry['name']}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Scanned At: ${entry['timestamp']}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Scanned Data:',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Table(
                                border: TableBorder.all(),
                                children: _buildRows(scannedData),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _normalizeScannedData(Map<String, dynamic> scannedData) {
  final keysToNormalize = ['Nitrogen', 'Phosphorous', 'Potassium'];

  scannedData.forEach((key, value) {
    if (keysToNormalize.contains(key)) {
      scannedData[key] = value.toString();
    }
  });
  return scannedData;
}

List<TableRow> _buildRows(Map<String, dynamic> scannedData) {
  final List<TableRow> rows = [];

  rows.add(buildRow("Nutrient", "Scanned", isHeader: true));

  final phValue = double.tryParse(scannedData['pH'] ?? '-1');
  rows.add(
    buildRow(
      "pH",
      phValue != null ? mapPHValue(phValue).toStringAsFixed(1) : "Invalid",
      isPH: true,
    ),
  );

  const nutrients = ["Nitrogen", "Phosphorus", "Potassium"];
  for (final nutrient in nutrients) {
    final scanned = scannedData[nutrient] ?? "0";
    final category = categorizeNutrient(scanned);
    rows.add(
      buildRow(
        nutrient,
        category,
      ),
    );
  }

  return rows;
}

double mapPHValue(double? scannedPH) {
  if (scannedPH == null) return 1.0;
  return 1 + (scannedPH * (13 / 25));
}

String categorizeNutrient(String? value) {
  if (value == null || value.isEmpty) {
    return 'Unknown';
  }
  try {
    int intValue = int.parse(value);
    double computedValue = (intValue * 1999) / 255;

    if (computedValue >= 0 && computedValue <= 299) {
      return 'LOW';
    } else if (computedValue >= 300 && computedValue <= 1000) {
      return 'MEDIUM';
    } else if (computedValue > 1000 && computedValue <= 1999) {
      return 'HIGH';
    } else {
      return 'Value is out of bounds.';
    }
  } catch (e) {
    return 'Invalid input.';
  }
}

Color determinePHColor(double? phValue) {
  if (phValue == null || phValue < 0 || phValue > 14) {
    return Colors.grey;
  }
  if (phValue >= 0 && phValue < 1) return Colors.green[800]!;
  if (phValue >= 1 && phValue < 3) return Colors.green[800]!;
  if (phValue >= 3 && phValue < 5) return Colors.green[800]!;
  if (phValue >= 5 && phValue < 6.5) return Colors.green[800]!;
  if (phValue >= 6.5 && phValue <= 7.5) return Colors.green[800]!;
  if (phValue > 7.5 && phValue <= 9) return Colors.green[800]!;
  if (phValue > 9 && phValue <= 11) return Colors.green[800]!;
  if (phValue > 11 && phValue <= 14) return Colors.green[800]!;
  return Colors.grey;
}

TableRow buildRow(String nutrient, String scanned,
    {bool isHeader = false, bool isPH = false}) {
  return TableRow(
    children: [
      Container(
        color:
            isHeader ? Color.fromARGB(255, 109, 109, 109) : Colors.transparent,
        padding: EdgeInsets.all(8.0),
        child: Text(
          nutrient,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      Container(
        color: isPH && !isHeader
            ? determinePHColor(double.tryParse(scanned) ?? -1)
            : isHeader
                ? Color.fromARGB(255, 109, 109, 109)
                : Colors.transparent,
        padding: EdgeInsets.all(8.0),
        child: Text(
          scanned,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}

Future<void> _generateAndSharePDF(
    Map<String, dynamic> entry, Map<String, dynamic> scannedData) async {
  final pdf = pw.Document();

  const relevantKeys = ['Nitrogen', 'Phosphorus', 'Potassium', 'pH'];
  final filteredScannedData = Map<String, dynamic>.fromEntries(
    scannedData.entries.where((entry) {
      if (!relevantKeys.contains(entry.key)) {
        print('Skipping irrelevant key: ${entry.key}');
      }
      return relevantKeys.contains(entry.key);
    }),
  );

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Crop: ${entry['name']}',
                  style: pw.TextStyle(
                      fontSize: 18.sp, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8.h),

              pw.Text('Scanned At: ${entry['timestamp']}',
                  style: pw.TextStyle(fontSize: 16.sp)),
              pw.SizedBox(height: 16.h),

              pw.Text('Scanned Data:',
                  style: pw.TextStyle(
                      fontSize: 18.sp, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8.h),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8.0),
                        child: pw.Text("Nutrient",
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8.0),
                        child: pw.Text("Result",
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),

                  ...filteredScannedData.entries.map((entry) {
                    String result;

                    if (entry.key == 'pH') {
                      final phValue = double.tryParse(entry.value ?? '-1');
                      result = phValue != null
                          ? mapPHValue(phValue).toStringAsFixed(1)
                          : "Invalid";
                    } else {
                      result = categorizeNutrient(entry.value);
                    }

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(entry.key),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8.0),
                          child: pw.Text(result),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  try {
    final label = entry['label'] ??
        'HistoryDetails'; 
    final sanitizedLabel = label
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');
    final directory = await getApplicationDocumentsDirectory();
    final file =
        File('${directory.path}/$sanitizedLabel.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'History Details PDF');
  } catch (e) {
    print('Error generating PDF: $e');
  }
}
