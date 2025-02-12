import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'db_helper.dart';
import 'vegetables.dart';
import 'edit_crop_screen.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
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

class ArchiveScreen extends StatefulWidget {
  final PageController pageController = PageController();
  final BluetoothDevice device;
  final double cardWidth = 300.0;
  final double cardHeight = 400.0;

  ArchiveScreen({
    required this.device,
  });
  
  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late Future<List<Map<String, dynamic>>> _archivedCropsFuture;

  @override
  void initState() {
    super.initState();
    _archivedCropsFuture = DBHelper.fetchArchivedCrops();
  }

  Future<void> _refreshArchivedCrops() async {
    setState(() {
      _archivedCropsFuture = DBHelper.fetchArchivedCrops();
    });
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
            title: 'Unarchive',
            icon: Icons.archive,
            color: Colors.green[50]!,
            iconColor: Colors.green[800]!,
            textColor: Colors.green[800]!,
            onTap: () {
              Navigator.pop(dialogContext, 'unarchive');
            },
          ),
        ],
      );
    },
  );

  if (option == 'edit') {
    _editCrop(context, crop);
  } else if (option == 'unarchive') {
    _unarchiveCrop(context, crop['id']);
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
        _refreshArchivedCrops();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to update crop')),
          );
        }
      }
    }
  }

  void _unarchiveCrop(BuildContext context, int cropId) async {
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
                'assets/images/alert/unarchive.png',
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
            // "Cancel" button
            Positioned(
              bottom: 320.h,
              right: 40.w,
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
        await DBHelper.unarchiveCrop(cropId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Crop unarchived successfully')),
          );
        }
        _refreshArchivedCrops();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to unarchive crop')),
          );
        }
      }
    }
  }

  Widget _buildCard(BuildContext context, String name, String description, String imagePath, Map<String, dynamic> crop) {
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.h)),
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
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
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
            'assets/images/BG/bg2.png',
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
                          width: 50.w,
                          height: 50.h,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          'Archived Crops',
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
          top: 150.h,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _archivedCropsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Failed to load archived crops'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No archived crops available'));
              }

              final crops = snapshot.data!;
              return Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: widget.pageController,
                      itemCount: crops.length,
                      itemBuilder: (context, index) {
                        final crop = crops[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => VDetails(
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
                          onLongPress: () => _showContextMenu(context, crop),
                          child: _buildCard(
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
                    padding: EdgeInsets.only(bottom: 120.0.h),
                    child: SmoothPageIndicator(
                      controller: widget.pageController,
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
        ),
      ],
    ),
  );
}
}