import 'dart:math';

import 'package:flutter/material.dart';
import 'colors.dart';

class SimpleLoader extends StatelessWidget {
  const SimpleLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 50,
        width: 50,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoaderContainerWithMessage extends StatefulWidget {
  final String message;
  final Color color1;
  final Color color2;
  final Color color3;

  const LoaderContainerWithMessage({
    super.key,
    required this.message,
    this.color1 = blue,
    this.color2 = blue,
    this.color3 = Colors.lightGreen,
  });

  @override
  LoaderContainerWithMessageState createState() => LoaderContainerWithMessageState();
}

class LoaderContainerWithMessageState extends State<LoaderContainerWithMessage> with TickerProviderStateMixin {
  late Animation<double> animation1;
  late Animation<double> animation2;
  late Animation<double> animation3;
  late AnimationController controller1;
  late AnimationController controller2;
  late AnimationController controller3;

  @override
  void initState() {
    super.initState();

    controller1 = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);

    controller2 = AnimationController(duration: const Duration(milliseconds: 900), vsync: this);

    controller3 = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller1, curve: const Interval(0.0, 1.0, curve: Curves.linear)));

    animation2 = Tween<double>(begin: -1.0, end: 0.0).animate(CurvedAnimation(parent: controller2, curve: const Interval(0.0, 1.0, curve: Curves.easeIn)));

    animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controller3, curve: const Interval(0.0, 1.0, curve: Curves.decelerate)));

    controller1.repeat();
    controller2.repeat();
    controller3.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: <Widget>[
                RotationTransition(
                  turns: animation1,
                  child: CustomPaint(
                    painter: Arc1Painter(widget.color1),
                    child: const SizedBox(
                      width: 50.0,
                      height: 50.0,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: animation2,
                  child: CustomPaint(
                    painter: Arc2Painter(widget.color2),
                    child: const SizedBox(
                      width: 50.0,
                      height: 50.0,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: animation3,
                  child: CustomPaint(
                    painter: Arc3Painter(widget.color3),
                    child: const SizedBox(
                      width: 50.0,
                      height: 50.0,
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
              child: Text(widget.message),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    controller3.dispose();
    super.dispose();
  }
}

class Arc1Painter extends CustomPainter {
  final Color color;
  final int numDots;
  final double dotSpacing;
  final double dotWidth;

  Arc1Painter(this.color, {this.numDots = 12, this.dotSpacing = 5.0, this.dotWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint p1 = Paint()
      ..color = color
      ..strokeWidth = dotWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final radius = min(size.width, size.height) / 2.0 - dotSpacing;
    final centerX = size.width / 2.0;
    final centerY = size.height / 2.0;

    for (int i = 0; i < numDots; i++) {
      final angle = 2 * pi * i / numDots;
      final startX = centerX + radius * cos(angle);
      final startY = centerY + radius * sin(angle);
      final endX = centerX + (radius - dotSpacing) * cos(angle);
      final endY = centerY + (radius - dotSpacing) * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), p1);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Arc2Painter extends CustomPainter {
  final Color color;
  final int numDots;
  final double dotSpacing;
  final double dotWidth;

  Arc2Painter(this.color, {this.numDots = 12, this.dotSpacing = 5.0, this.dotWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint p1 = Paint()
      ..color = color
      ..strokeWidth = dotWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final radius = min(size.width, size.height) / 2.0 - dotSpacing;
    final centerX = size.width / 2.0;
    final centerY = size.height / 2.0;

    for (int i = 0; i < numDots; i++) {
      final angle = 2 * pi * i / numDots;
      final startX = centerX + radius * cos(angle);
      final startY = centerY + radius * sin(angle);
      final endX = centerX + (radius - dotSpacing) * cos(angle);
      final endY = centerY + (radius - dotSpacing) * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), p1);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// Modify Arc2Painter and Arc3Painter similarly

class Arc3Painter extends CustomPainter {
  final Color color;

  Arc3Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint p3 = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect3 = Rect.fromLTWH(0.0 + (0.4 * size.width) / 2, 0.0 + (0.4 * size.height) / 2, size.width - 0.4 * size.width, size.height - 0.4 * size.height);

    canvas.drawArc(rect3, 0.0, 0.9 * pi, false, p3);
    canvas.drawArc(rect3, 1.1 * pi, 0.8 * pi, false, p3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
