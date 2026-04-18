import 'dart:ui';

import 'package:flutter/material.dart';

import '../controllers/map_home_state.dart';

class EchoBottomCard extends StatelessWidget {
  final EchoPreview echo;
  final String buttonText;
  final bool canOpen;
  final bool canLike;
  final VoidCallback onOpenTap;
  final VoidCallback onNextTap;

  const EchoBottomCard({super.key,
    required this.echo,
    required this.buttonText,
    required this.canOpen,
    required this.canLike,
    required this.onOpenTap,
    required this.onNextTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeConfig = _echoTypeConfig(echo.type);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.black.withValues(alpha: 0.20),              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(colors: typeConfig.gradient),
                      ),
                      child: Icon(
                        typeConfig.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            typeConfig.label,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            echo.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onNextTap,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.place_rounded,
                      text: echo.distanceText,
                      color: const Color(0xFF66F5AF),
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.favorite_rounded,
                      text: '${echo.likes}',
                      color: const Color(0xFFFF6AA2),
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.chat_bubble_rounded,
                      text: '${echo.comments}',
                      color: const Color(0xFF56C8FF),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: onOpenTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canOpen
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.22),
                            foregroundColor: canOpen
                                ? Colors.black
                                : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Opacity(
                      opacity: canLike ? 1 : 0.45,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white.withValues(alpha: 0.10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  _EchoTypeVisual _echoTypeConfig(EchoType type) {
    switch (type) {
      case EchoType.unlocked:
        return const _EchoTypeVisual(
          label: 'Echo gần bạn nhất',
          icon: Icons.lock_open_rounded,
          gradient: [Color(0xFF66F5AF), Color(0xFF4EC8FF)],
        );
      case EchoType.locked:
        return const _EchoTypeVisual(
          label: 'Echo đang khóa',
          icon: Icons.lock_rounded,
          gradient: [Color(0xFF8B7BFF), Color(0xFF5C6CFF)],
        );
      case EchoType.capsule:
        return const _EchoTypeVisual(
          label: 'Time Capsule',
          icon: Icons.hourglass_top_rounded,
          gradient: [Color(0xFFFFB84D), Color(0xFFFF7A59)],
        );
      case EchoType.ghost:
        return const _EchoTypeVisual(
          label: 'Ghost Echo',
          icon: Icons.visibility_off_rounded,
          gradient: [Color(0xFFE56CFF), Color(0xFF8B7BFF)],
        );
    }
  }
}


class _EchoTypeVisual {
  final String label;
  final IconData icon;
  final List<Color> gradient;

  const _EchoTypeVisual({
    required this.label,
    required this.icon,
    required this.gradient,
  });
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}