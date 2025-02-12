import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'db_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditCropScreen extends StatefulWidget {
  final Map<String, dynamic> crop;

  EditCropScreen({Key? key, required this.crop}) : super(key: key);

  @override
  _EditCropScreenState createState() => _EditCropScreenState();
}

class _EditCropScreenState extends State<EditCropScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _nitrogen;
  late String _phosphorous;
  late String _potassium;
  late double _ph;
  late String _status;
  String? _imagePath;
  File? _imageFile;

  @override
  void initState() {
    super.initState();

    _name = widget.crop['name'];
    _description = widget.crop['description'];
    _nitrogen = widget.crop['nitrogen'];
    _phosphorous = widget.crop['phosphorous'];
    _potassium = widget.crop['potassium'];
    _ph = widget.crop['ph'];
    _status = widget.crop['status'];

    final path = widget.crop['image_path'];
    if (path != null) {
      if (path.startsWith('assets/')) {
        _imagePath = path;
      } else {
        _imageFile = File(path);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imagePath = null;
      });
    }
  }

  Future<void> _saveCrop() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final isDuplicate = await DBHelper.cropNameExists(_name);
      if (isDuplicate && _name != widget.crop['name']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Crop name '$_name' already exists. Please choose a different name."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updatedImagePath = _imageFile?.path ?? _imagePath;

      final updatedCrop = {
        'id': widget.crop['id'],
        'name': _name,
        'description': _description,
        'image_path': updatedImagePath,
        'nitrogen': _nitrogen,
        'phosphorous': _phosphorous,
        'potassium': _potassium,
        'ph': _ph,
        'status': _status,
      };

      Navigator.pop(context, updatedCrop);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                            'Edit Crop',
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
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      TextFormField(
                        initialValue: _name,
                        decoration: InputDecoration(
                          labelText: "Crop Name",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Required" : null,
                        onSaved: (value) => _name = value!,
                      ),
                      SizedBox(height: 10.h),
                      TextFormField(
                        initialValue: _description,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        validator: (value) =>
                            value!.isEmpty ? "Required" : null,
                        onSaved: (value) => _description = value!,
                      ),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String>(
                        value: _nitrogen,
                        decoration: InputDecoration(
                          labelText: "Nitrogen Level",
                          border: OutlineInputBorder(),
                        ),
                        items: ["HIGH", "MEDIUM", "LOW"]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) => _nitrogen = value!,
                        onSaved: (value) => _nitrogen = value!,
                      ),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String>(
                        value: _phosphorous,
                        decoration: InputDecoration(
                          labelText: "Phosphorous Level",
                          border: OutlineInputBorder(),
                        ),
                        items: ["HIGH", "MEDIUM", "LOW"]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) => _phosphorous = value!,
                        onSaved: (value) => _phosphorous = value!,
                      ),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String>(
                        value: _potassium,
                        decoration: InputDecoration(
                          labelText: "Potassium Level",
                          border: OutlineInputBorder(),
                        ),
                        items: ["HIGH", "MEDIUM", "LOW"]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) => _potassium = value!,
                        onSaved: (value) => _potassium = value!,
                      ),
                      SizedBox(height: 10.h),
                      TextFormField(
                        initialValue: _ph.toString(),
                        decoration: InputDecoration(
                          labelText: "pH",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Required";
                          }
                          final double? phValue = double.tryParse(value);
                          if (phValue == null || phValue < 0 || phValue > 14) {
                            return "Enter a valid pH between 0 and 14";
                          }
                          return null;
                        },
                        onSaved: (value) => _ph = double.parse(value!),
                      ),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: InputDecoration(
                          labelText: "Status",
                          border: OutlineInputBorder(),
                        ),
                        items: ["ACTIVE", "INACTIVE"]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) => _status = value!,
                        onSaved: (value) => _status = value!,
                      ),
                      SizedBox(height: 10.h),
                      Center(
                        child: _buildImagePreview(),
                      ),
                      Center(
                        child: TextButton.icon(
                          icon: Icon(Icons.image),
                          label: Text("Pick Image"),
                          onPressed: _pickImage,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: GestureDetector(
                          onTap: _saveCrop,
                          child: Image.asset(
                            'assets/images/button/save.png',
                            width: 100.w,
                            height: 50.h,
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
    );
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, height: 150.h);
    } else if (_imagePath != null) {
      return Image.asset(_imagePath!, height: 150.h, fit: BoxFit.cover);
    } else {
      return Text("No image selected");
    }
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
