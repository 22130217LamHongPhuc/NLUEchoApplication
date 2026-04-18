import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PulseEchoMarker extends StatefulWidget {
  final Color color;
  final IconData icon;
  final bool isSelected;

  const PulseEchoMarker({
    super.key,
    required this.color,
    required this.icon,
    this.isSelected = false,
  });

  @override
  State<PulseEchoMarker> createState() => _PulseEchoMarkerState();
}

class _PulseEchoMarkerState extends State<PulseEchoMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseSize = widget.isSelected ? 28.0 : 22.0;

    return SizedBox(
      width: 88,
      height: 88,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 0.6 + (_controller.value * 1.15);
          final opacity = (1 - _controller.value).clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: baseSize + 42 * scale,
                height: baseSize + 42 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.22 * opacity),
                ),
              ),
              Container(
                width: baseSize,
                height: baseSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.66),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: widget.isSelected ? 15 : 13,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}