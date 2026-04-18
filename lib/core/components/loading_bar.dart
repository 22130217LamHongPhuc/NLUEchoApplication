import 'package:flutter/material.dart';

class LoadingBar extends StatelessWidget {
  final String? text;
  final double size;
  final Color color;

  const LoadingBar({
    super.key,
    this.text,
    this.size = 30,
    this.color = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),

          if (text != null) ...[
            const SizedBox(height: 12),
            Text(
              text!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ]
        ],
      ),
    );
  }
}