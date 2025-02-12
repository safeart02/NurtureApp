import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'db_helper.dart';
import 'add_crop_screen.dart';
import 'dart:io';
import 'main.dart';
import 'animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'edit_crop_screen.dart';
import 'archive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const List<String> defaultCropNames = [
  'Banana',
  'Okra',
  'Sweet Potato',
  'Talong',
  'Cucumber',
];

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

class VSelect extends StatefulWidget {
  final BluetoothDevice device;
  final double cardWidth;
  final double cardHeight;

  VSelect({
    required this.device,
    this.cardWidth = 300.0,
    this.cardHeight = 400.0,
  });

  @override
  _VSelectState createState() => _VSelectState();
}

class _VSelectState extends State<VSelect> {
  final PageController _pageController = PageController();
  late Future<List<Map<String, dynamic>>> _cropsFuture;

  @override
  void initState() {
    super.initState();
    _cropsFuture = DBHelper.fetchCrops();
  }

  Future<void> _refreshCrops() async {
    setState(() {
      _cropsFuture = DBHelper.fetchCrops();
    });
  }

  Future<void> _backupCrops(BuildContext context) async {
    try {
      final crops = await DBHelper.fetchCrops();
      if (crops.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No crops available to backup')),
        );
        return;
      }

      final cropsDirectory = Directory('/storage/emulated/0/Download/Crops');
      if (!await cropsDirectory.exists()) {
        await cropsDirectory.create(recursive: true);
      }

      String sqlContent = "";
      for (var crop in crops) {
        final name = crop['name'];
        final description = crop['description'];
        final imagePath = crop['image_path'];
        final nitrogen = crop['nitrogen'];
        final phosphorous = crop['phosphorous'];
        final potassium = crop['potassium'];
        final ph = crop['ph'];
        final status = crop['status'];

        String permanentImagePath = imagePath;
        if (imagePath.isNotEmpty) {
          final fileName = basename(imagePath);
          final imageFile = File(imagePath);

          if (await imageFile.exists()) {
            permanentImagePath = '/storage/emulated/0/Download/Crops/$fileName';
            await imageFile.copy(permanentImagePath);
          }
        }

        sqlContent +=
            "INSERT OR REPLACE INTO crops (name, description, image_path, nitrogen, phosphorous, potassium, ph, status) "
            "VALUES ('$name', '$description', '$permanentImagePath', '$nitrogen', '$phosphorous', '$potassium', $ph, '$status');\n";
      }

      final fileName = await _getFileNameFromUser(context);
      if (fileName == null || fileName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File name cannot be empty')),
        );
        return;
      }

      final downloadPath = "/storage/emulated/0/Download/$fileName.txt";
      final file = File(downloadPath);
      await file.writeAsString(sqlContent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup saved to $downloadPath')),
      );
    } catch (e) {
      print("Error during backup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to backup crops')),
      );
    }
  }

  Future<String?> _getFileNameFromUser(BuildContext context) async {
    String? fileName;
    return showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Enter File Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter backup file name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                fileName = controller.text.trim();
                if (fileName!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('File name cannot be empty')),
                  );
                } else {
                  Navigator.of(context).pop(fileName);
                }
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _checkAndRequestManageExternalStorage() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    if (Platform.isAndroid) {
      await Permission.manageExternalStorage.request();

      if (!await Permission.manageExternalStorage.isGranted) {
        await openAppSettings();
        return false;
      }
    }
    return true;
  }

  Future<void> _restoreCrops(BuildContext context) async {
    try {
      final hasPermission = await _checkAndRequestManageExternalStorage();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission to access files is required.')),
        );
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result == null || result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No file selected')),
        );
        return;
      }

      final filePath = result.files.single.path!;
      final fileContent = await File(filePath).readAsString();

      final sqlQueries = fileContent
          .split(';')
          .map((query) => query.trim())
          .where((q) => q.isNotEmpty);

      int successCount = 0;
      int failureCount = 0;

      final appDocumentsDirectory = await getApplicationDocumentsDirectory();
      final cropsImageDirectory =
          Directory(join(appDocumentsDirectory.path, 'images', 'Crops'));
      if (!await cropsImageDirectory.exists()) {
        await cropsImageDirectory.create(recursive: true);
      }

      final brokenImagePath = join(appDocumentsDirectory.path, 'images',
          'assets/images/broken_image.png');

      for (final query in sqlQueries) {
        try {
          final regex = RegExp(r"VALUES\s*\('(.+?)',", caseSensitive: false);
          final match = regex.firstMatch(query);

          if (match != null) {
            final cropIdentifier = match.group(1)!;

            final exists = await DBHelper.cropNameExists(cropIdentifier);

            if (exists) {
              failureCount++;
              continue;
            }
          }

          final imageRegex =
              RegExp(r"VALUES\s*\(.+?,.+?,\s*'(.+?)'", caseSensitive: false);
          final imageMatch = imageRegex.firstMatch(query);

          if (imageMatch != null) {
            final originalImagePath = imageMatch.group(1)!;
            String newImagePath;

            try {
              newImagePath = await _moveImageToInternalStorage(
                  originalImagePath, cropsImageDirectory);
            } catch (e) {
              print(
                  "Image not found: $originalImagePath, using broken image placeholder.");
              newImagePath = brokenImagePath;
            }

            final updatedQuery =
                query.replaceFirst(originalImagePath, newImagePath);

            await DBHelper.executeSQL(updatedQuery);
          } else {
            await DBHelper.executeSQL(query);
          }

          successCount++;
        } catch (e) {
          print("Error processing query: $query\nReason: $e");
          failureCount++;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '$successCount crops merged successfully, $failureCount crops already exist.')),
      );
      await _refreshCrops();
    } catch (e) {
      print("Critical error during merging: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to merge crops')),
      );
    }
  }

  Future<String> _moveImageToInternalStorage(
      String originalPath, Directory cropsImageDirectory) async {
    final fileName = basename(originalPath);
    final newImagePath = join(cropsImageDirectory.path, fileName);

    final originalImageFile = File(originalPath);
    if (!await originalImageFile.exists()) {
      throw Exception("Image not found at path: $originalPath");
    }

    try {
      await originalImageFile.copy(newImagePath);
    } catch (e) {
      throw Exception('Failed to copy image: $e');
    }

    return newImagePath;
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      color: color,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showContextMenu(BuildContext context, Map<String, dynamic> crop) async {
    final isDefault = defaultCropNames.contains(crop['name']);

    final option = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDefault)
              _buildMenuTile(
                context: dialogContext,
                title: 'Edit',
                icon: Icons.edit,
                color: Colors.green[50]!,
                iconColor: Colors.green[800]!,
                textColor: Colors.green[800]!,
                onTap: () {
                  Navigator.pop(dialogContext, 'edit');
                },
              ),
            _buildMenuTile(
              context: dialogContext,
              title: 'Archive',
              icon: Icons.archive,
              color: Colors.green[50]!,
              iconColor: Colors.green[800]!,
              textColor: Colors.green[800]!,
              onTap: () {
                Navigator.pop(dialogContext, 'archive');
              },
            ),
          ],
        );
      },
    );

    if (option == 'edit') {
      _editCrop(context, crop);
    } else if (option == 'archive') {
      _archiveCrop(context, crop['id']);
    }
  }

  void _editCrop(BuildContext context, Map<String, dynamic> crop) async {
    final updatedCrop = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => EditCropScreen(crop: crop),
      ),
    );

    if (updatedCrop != null) {
      try {
        await DBHelper.updateCrop(updatedCrop);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Crop updated successfully')),
          );
        }
        _refreshCrops();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update crop')),
          );
        }
      }
    }
  }

  void _archiveCrop(BuildContext context, int cropId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                bottom: 150.h,
                child: Image.asset(
                  'assets/images/alert/archive.png',
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
                    Navigator.of(context).pop(true);
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
                right: 40.h,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false);
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
    );

    if (confirmed == true) {
      try {
        await DBHelper.archiveCrop(cropId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Crop archived successfully')),
          );
        }
        _refreshCrops();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to archive crop')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/BG/bg7.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0.h,
              left: 0.w,
              right: 0.w,
              child: Container(
                height: 100.h,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 120),
                  painter: ConvexAppBarPainter(),
                  child: IgnorePointer(
                    child: Center(
                      child: Text(
                        'Select Crop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _cropsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load crops'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No crops available'));
                }

                final crops = snapshot.data!;
                return Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: crops.length,
                        itemBuilder: (context, index) {
                          final crop = crops[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                RightToLeftTransition(
                                  page: VDetails(
                                    name: crop['name'],
                                    description: crop['description'],
                                    image: crop['image_path'],
                                    nutrientData: {
                                      'Nitrogen': crop['nitrogen'],
                                      'Phosphorus': crop['phosphorous'],
                                      'Potassium': crop['potassium'],
                                      'pH': crop['ph'].toString(),
                                    },
                                    device: widget.device,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
                              _showContextMenu(context, crop);
                            },
                            child: buildCard(
                              context,
                              crop['name'],
                              crop['description'],
                              crop['image_path'],
                              crop,
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 180.0.h),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: crops.length,
                        effect: WormEffect(
                          dotHeight: 16,
                          dotWidth: 16,
                          activeDotColor: Colors.white,
                          dotColor: Colors.green[700]!,
                        ),
                      ),
                    ),
                  ],
                );
              },
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
              print("Archive button function triggered");
              try {
                assert(widget.device != null, 'Device is null');
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArchiveScreen(device: widget.device),
                  ),
                );
                _refreshCrops();
              } catch (e) {
                print("Archive Button Error: $e");
              }
            },
            icon: Icon(Icons.archive, color: Colors.white),
          ),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
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
              print("Popup menu function triggered");
              try {
                final result = await showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(100, 650, 0, 0),
                  items: [
                    PopupMenuItem<String>(
                      value: 'addCrop',
                      child: Container(
                        color: Colors.green[800]!,
                        width: double.infinity.w,
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0.h, horizontal: 10.0.w),
                        child: Text(
                          'Add Crop',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'backupCrops',
                      child: Container(
                        color: Colors.green[800]!,
                        width: double.infinity.w,
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0.h, horizontal: 10.0.w),
                        child: Text(
                          'Backup Crops to File',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'restoreCrops',
                      child: Container(
                        color: Colors.green[800]!,
                        width: double.infinity.w,
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0.h, horizontal: 10.0.w),
                        child: Text(
                          'Merge Crops from File',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );

                if (result != null) {
                  if (result == 'addCrop') {
                    final newCropAdded = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddCropScreen()),
                    );
                    if (newCropAdded == true) _refreshCrops();
                  } else if (result == 'backupCrops') {
                    await _backupCrops(context);
                  } else if (result == 'restoreCrops') {
                    await _restoreCrops(context);
                  }
                }
              } catch (e) {
                print("Popup Menu Error: $e");
              }
            },
            icon: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
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
                return Dialog(
                  backgroundColor: Colors.transparent,
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
            );
          },
          child: Icon(
            Icons.home,
            color: Colors.white,
          ),
          backgroundColor: Color.fromARGB(141, 46, 125, 50),
          tooltip: 'Go to Main Menu',
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, String name, String description,
      String imagePath, Map<String, dynamic> crop) {
    return Center(
      child: SizedBox(
        width: widget.cardWidth.w,
        height: widget.cardHeight.h,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.h)),
                  child: imagePath.startsWith('assets/')
                      ? Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity.w,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 100);
                          },
                        )
                      : Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          width: double.infinity.w,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image, size: 100);
                          },
                        ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26.sp,
                  ),
                  textAlign:
                      TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VDetails extends StatelessWidget {
  final String name;
  final String description;
  final String image;
  final Map<String, String> nutrientData;
  final BluetoothDevice device;

  VDetails({
    required this.name,
    required this.description,
    required this.image,
    required this.nutrientData,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent,
      body: Stack(
        children: [
          // Background Image
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
                            '$name Details',
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
            top: 110.h,
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context)
                    .size
                    .height,
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0.h),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 300.w,
                          height: 300.h,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: image.startsWith('assets/')
                                  ? Image.asset(
                                      image,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.broken_image,
                                            size: 100);
                                      },
                                    )
                                  : Image.file(
                                      File(image),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.broken_image,
                                            size: 100);
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: Container(
                          width: 300.w,
                          child: Card(
                            color: Colors.green[800]!,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 236, 236, 236),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Color.fromARGB(255, 236, 236, 236),
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            RightToLeftTransition(
                              page: VRequirements(
                                name: name,
                                nutrientData: nutrientData,
                                device: device,
                                image: image,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/button/requirements.png',
                          width: 250.w,
                          height: 120.h,
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
    );
  }
}
