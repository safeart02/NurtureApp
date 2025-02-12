import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'vegetables.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReminderScreen extends StatelessWidget {
  final BluetoothDevice device;

  const ReminderScreen({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity.w,
            height: double.infinity.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BG/bg3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0.h,
            left: 0.w,
            right: 0.w,
            child: Container(
              width: double.infinity.w,
              height: 500.h,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/foreground/reminder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 200.0.h, left: 20.w),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VSelect(device: device)),
                  );
                },
                child: Image.asset(
                  'assets/images/button/proceed.png',
                  height: 100.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
