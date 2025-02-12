import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'db_helper.dart';
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

class AddCropScreen extends StatefulWidget {
  @override
  _AddCropScreenState createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name, _description, _nitrogen, _phosphorous, _potassium, _status;
  double? _ph;
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveCrop() async {
    if (_formKey.currentState!.validate() && _image != null) {
      _formKey.currentState!.save();

      bool nameExists = await DBHelper.cropNameExists(_name!);

      if (nameExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Crop name '$_name' already exists. Please choose a different name."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        await DBHelper.insertCrop({
          'name': _name!,
          'description': _description!,
          'image_path': _image!.path,
          'nitrogen': _nitrogen!,
          'phosphorous': _phosphorous!,
          'potassium': _potassium!,
          'ph': _ph!,
          'status': _status!,
        });

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "An error occurred while saving the crop. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select an image."),
          backgroundColor: Colors.red,
        ),
      );
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
                            'Add Crop',
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
                      _buildModernTextField(
                        label: "Crop Name",
                        icon: Icons.spa,
                        onSaved: (value) => _name = value,
                        validator: (value) =>
                            value!.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 10.h),
                      _buildModernTextField(
                        label: "Description",
                        icon: Icons.description,
                        onSaved: (value) => _description = value,
                        validator: (value) =>
                            value!.isEmpty ? "Required" : null,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                      SizedBox(height: 10.h),
                      _buildDropdownField(
                        label: "Nitrogen Level",
                        items: ["HIGH", "MEDIUM", "LOW"],
                        onChanged: (value) => _nitrogen = value,
                      ),
                      SizedBox(height: 10.h),
                      _buildDropdownField(
                        label: "Phosphorous Level",
                        items: ["HIGH", "MEDIUM", "LOW"],
                        onChanged: (value) => _phosphorous = value,
                      ),
                      SizedBox(height: 10.h),
                      _buildDropdownField(
                        label: "Potassium Level",
                        items: ["HIGH", "MEDIUM", "LOW"],
                        onChanged: (value) => _potassium = value,
                      ),
                      SizedBox(height: 10.h),
                      _buildModernTextField(
                        label: "pH",
                        icon: Icons.science,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        onSaved: (value) => _ph = double.tryParse(value!),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Required";
                          }
                          final double? ph = double.tryParse(value);
                          if (ph == null || ph < 0 || ph > 14) {
                            return "Enter a valid pH between 0 and 14";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.h),
                      _buildDropdownField(
                        label: "Status",
                        items: ["ACTIVE", "INACTIVE"],
                        onChanged: (value) => _status = value,
                      ),
                      SizedBox(height: 10.h),
                      Center(
                        child: _image != null
                            ? Image.file(_image!, height: 150.h)
                            : Text("No image selected"),
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
                            width: 100.h,
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

  Widget _buildModernTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines =
        1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
