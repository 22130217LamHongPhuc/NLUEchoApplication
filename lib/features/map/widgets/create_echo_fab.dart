import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateEchoFab extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const CreateEchoFab({
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF64F4AC), Color(0xFF6C7BFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64F4AC).withOpacity(0.34),
              blurRadius: 28,
              spreadRadius: 1,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: onTap,
          child: const Icon(
            Icons.add_rounded,
            size: 34,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}