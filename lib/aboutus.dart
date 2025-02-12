import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
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


class _AboutUsState extends State<AboutUs> {
  final List<Map<String, String>> researchers = [
    {
      'imageUrl': 'assets/images/About/brian.png',
      'name': 'Bryan Miguel Añonuevo',
      'role': 'Communications Coordinator',
      'description': """Email: anonuevobryanmiguel@gmail.com
Facebook: https://facebook.com/bryanmiguel.anonuevo16"""
    },
    {
      'imageUrl': 'assets/images/About/erica.png',
      'name': 'Erica Enriquez',
      'role': 'Researcher / Documentor / Quality Assurance',
      'description': """Email: enriquezerica504@gmail.com
Facebook: https://facebook.com/erica.enriquez.1112"""
    },
    {
      'imageUrl': 'assets/images/About/alecs.png',
      'name': 'Alecs Parra Paterno',
      'role': 'Lead Researcher / Lead Documentor / Quality Assurance',
      'description': """Email: alecs.paternofcp@gmail.com
Facebook: https://facebook.com/paternoalexi.fcp"""
    },
    {
      'imageUrl': 'assets/images/About/rhyz.png',
      'name': 'Rhyz-chelle Silva',
      'role': 'UI Designer / Documentor / Quality Assurance',
      'description': """Email: tammysilva062804@gmail.com
Facebook: https://facebook.com/rhyz.silva0501"""
    },
    {
      'imageUrl': 'assets/images/About/ken.png',
      'name': 'Ken Lester Fontanilla Taupo',
      'role': 'Programmer / System Architech / Technology Researcher',
      'description': """Email: fontanillaken19@gmail.com
Facebook: https://facebook.com/malabopapo"""
    },
  ];

  final List<Map<String, String>> institutions = [
    {
      'imageUrl': 'assets/images/LOGO/cct.png',
      'name': 'City College of Tagaytay',
      'role': 'College',
      'description': 'The City College of Tagaytay in Tagaytay City is an institution of higher learning, a Local College, which was established by virtue of City Ordinance 2002-229.'
    },
    {
      'imageUrl': 'assets/images/LOGO/SCS.png',
      'name': 'School of Computer Studies',
      'role': 'IT Department',
      'description': 'Department committed to produce globally competitive graduates in the field of Computer Science and Information Technology responsive to the challenging needs of society.'
    },
    {
      'imageUrl': 'assets/images/LOGO/DA.png',
      'name': 'Department of Agriculture',
      'role': 'Agriculture Advisor',
      'description': 'Executive department of the Philippine government responsible for the promotion of agricultural and fisheries development and growth.'
    },
  ];

Widget _buildResearcherCard(Map<String, String> researcher) {
  TextSpan _parseDescription(String description) {
    List<TextSpan> spans = [];
    var lines = description.split('\n');
    for (var line in lines) {
      if (line.startsWith('Email:')) {
        var email = line.replaceFirst('Email:', '').trim();
        spans.add(TextSpan(
          children: [
            WidgetSpan(
              child: Icon(Icons.email, size: 20, color: Colors.black),
            ),
            TextSpan(text: ' $email\n', style: TextStyle(color: Colors.black)),
          ],
        ));
      } else if (line.startsWith('Facebook:')) {
        var facebook = line.replaceFirst('Facebook:', '').trim();
        spans.add(TextSpan(
          children: [
            WidgetSpan(
              child: Icon(Icons.facebook, size: 20, color: Colors.black),
            ),
            TextSpan(text: ' $facebook\n', style: TextStyle(color: Colors.black)),
          ],
        ));
      } else {
        spans.add(TextSpan(text: '$line\n', style: TextStyle(color: Colors.black)));
      }
    }
    return TextSpan(children: spans);
  }

  return SizedBox(
    width: 345.w,
    child: Card(
      color: Color.fromARGB(255, 117, 192, 119),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                researcher['imageUrl']!,
                width: 100.w,
                height: 100.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              researcher['name']!,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
            researcher['role']!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Color.fromARGB(255, 88, 88, 88),
            ),
            textAlign: TextAlign.center,
          ),
            SizedBox(height: 8.h),
            RichText(
              text: _parseDescription(researcher['description']!),
            ),
            SizedBox(height: 8.h),

          ],
        ),
      ),
    ),
  );
}




  Widget _buildInstitutionCard(Map<String, String> institution) {
  return SizedBox(
    width: 300.w,
    child: Card(
      color: Color.fromARGB(255, 117, 192, 119),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.asset(
                institution['imageUrl']!,
                width: 100.w,
                height: 100.h,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              institution['name']!,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              institution['description']!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Color.fromARGB(255, 88, 88, 88),
              ),
              textAlign: TextAlign.center,
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
              'assets/images/BG/bg6.png',
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
                            'ABOUT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16.w,
                        bottom: 40.h,
                        child: IconButton(
                          icon: Icon(Icons.qr_code, color: Color.fromARGB(255, 255, 255, 255)),
                          onPressed: () {
                            _showQRCodePopup(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        _buildExpandableCard(
                          title: "         ABOUT",
                          content:
                              """Welcome to Utilizing Arduino Technology for Real-Time Soil Nutrient Analysis, a cutting-edge application designed to modernize agricultural practices in Department of Agriculture, Tagaytay City, specifically in identifying the level of nutrient present in the soil, such as Nitrogen (N), Phosphorus (P), Potassium (K), and pH. This app is developed by students of the City College of Tagaytay, School of Computer Studies Department, which utilizes Arduino technology to deliver real-time data on soil nutrient level, providing the user with essential insights for effective crop management. 

Key Features:
•	Real-Time Soil Nutrient Analysis: Instantly measure and analyze nutrients such as nitrogen, phosphorus, potassium, pH levels, and moisture of the soil.
•	Crop-Specific Soil Testing: Select a crop to plant, then test the soil to receive tailored fertilizer recommendations.
•	Comprehensive Crop Information Management: Add, update, and archive crop information efficiently.
•	Data Backup and Synchronization: Save crop nutrient analysis data backups that can be merged across multiple android devices for seamless access.
•	Fertilizer Recommendations: Provide suggestions on the type and quantity of fertilizer to optimize soil health. For built-in crops, specific fertilizer recommendations are available, while user-added crops are limited to organic fertilizer recommendations.
•	Soil Analysis History: Save detailed soil nutrient analysis reports in PDF format for future reference.

This app is proudly developed to support Tagaytay's agricultural sector in achieving its goals of productivity, sustainability, and innovation.  

For inquiries or assistance, please reach out to us at break.soil2024@gmail.com or 0945-342-6301.

Thank you for trusting Utilizing Arduino Technology for Real-Time Soil Nutrient Analysis! Together, we cultivate a brighter future for agriculture.""",
                        ),
                        SizedBox(height: 10.h),
                        _buildExpandableCreditCard(
                          title: "         CREDITS",
                          content:
                              """Copyright 2020 The Poppins Project Authors (https://github.com/itfoundry/Poppins)

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM
OTHER DEALINGS IN THE FONT SOFTWARE.""",
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          height: 290.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(vertical: 12.w),
                            itemCount: researchers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: _buildResearcherCard(researchers[index]),
                              );
                            },
                          ),
                        ),

                        SizedBox(
                          height: 300.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(vertical: 12.w),
                            itemCount: institutions.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: _buildInstitutionCard(institutions[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  

  Widget _buildExpandableCard({required String title, required String content}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Color.fromARGB(255, 117, 192, 119),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              content,
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCreditCard({required String title, required String content}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Color.fromARGB(255, 117, 192, 119),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              content,
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }



  void _showQRCodePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("QR Code", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/About/qr.png'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
