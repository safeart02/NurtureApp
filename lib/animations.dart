import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class LinePainter extends CustomPainter {
  final double progress;

  LinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2;

    Path path = Path()
      ..moveTo(centerX - radius, centerY)
      ..arcTo(Rect.fromLTWH(centerX - radius, centerY - radius, 2 * radius, 2 * radius), -1.5 * 3.14, 3.14 * 2 * progress, false)
      ..lineTo(centerX + radius + 20, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CircleLinePainter extends CustomPainter {
  final double progress;

  CircleLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2 - 10;

    Path path = Path();
    double startAngle = -pi / 2;
    double sweepAngle = 2 * pi * progress;

    path.addArc(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius), startAngle, sweepAngle);

    canvas.drawPath(path, paint);

    if (progress > 2.0) {
      double extraLength = 20;
      Paint extraPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(centerX + radius, centerY),
        Offset(centerX + radius + extraLength, centerY),
        extraPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class WipePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  WipePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

class BottomToTopTransition extends PageRouteBuilder {
  final Widget page;

  BottomToTopTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0, 1);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var opacityTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

            var slideAnimation = animation.drive(tween);
            var fadeAnimation = animation.drive(opacityTween);

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}

class RightToLeftTransition extends PageRouteBuilder {
  final Widget page;

  RightToLeftTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1, 0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var opacityTween = Tween<double>(begin: 0.6, end: 1.0).chain(CurveTween(curve: curve));

            var slideAnimation = animation.drive(tween);
            var fadeAnimation = animation.drive(opacityTween);

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}
