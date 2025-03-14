import 'package:flutter/material.dart';

class CircularProgressWithText extends StatelessWidget {
  final double progress;
  final String text;
  final double size;
  final Color progressColor;
  final Color backgroundColor;

  const CircularProgressWithText({
    super.key,
    required this.progress,
    required this.text,
    this.size = 100.0,
    this.progressColor = Colors.blue,
    this.backgroundColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8.0,
                backgroundColor: backgroundColor,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
