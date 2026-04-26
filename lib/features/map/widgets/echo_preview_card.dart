import 'package:flutter/material.dart';
import '../models/echo_preview.dart';


class EchoPreviewCard extends StatelessWidget {
  final EchoPreview echo;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  const EchoPreviewCard({
    super.key,
    required this.echo,
    required this.onClose,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isAnonymous = echo.anonymous == true;
    final isCapsule = echo.capsule == true;

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE9EDF2)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 24,
                offset: Offset(0, 10),
                color: Color(0x14000000),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EchoAvatar(
                isAnonymous: isAnonymous,
                isCapsule: isCapsule,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title + close
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            echo.title.isEmpty ? 'Untitled Echo' : echo.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onClose,
                          borderRadius: BorderRadius.circular(99),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.place_outlined,
                          label: _formatDistance(echo.distance),
                        ),
                        if (isCapsule)
                          const _StatusChip(
                            icon: Icons.lock_clock,
                            label: 'Capsule',
                            background: Color(0xFFFFF4DB),
                            foreground: Color(0xFFB7791F),
                          ),
                        if (isAnonymous)
                          const _StatusChip(
                            icon: Icons.visibility_off_outlined,
                            label: 'Ghost',
                            background: Color(0xFFF3F4F6),
                            foreground: Color(0xFF6B7280),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _MiniInfo(
                          icon: Icons.favorite_border,
                          text: '${echo.likes}',
                        ),
                        const SizedBox(width: 14),
                        _MiniInfo(
                          icon: Icons.mode_comment_outlined,
                          text: '${echo.comments}',
                        ),
                        if (echo.unlockTime != null) ...[
                          const SizedBox(width: 14),
                          _MiniInfo(
                            icon: Icons.schedule,
                            text: _formatUnlockTime(echo.unlockTime!),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed: onOpen,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF111827),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isCapsule ? 'Xem chi tiết' : 'Mở Echo',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDistance(double distance) {
    if (distance < 1) {
      final meters = (distance * 1000).round();
      return '$meters m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  static String _formatUnlockTime(DateTime time) {
    return '${time.day}/${time.month}';
  }
}

class _EchoAvatar extends StatelessWidget {
  final bool isAnonymous;
  final bool isCapsule;

  const _EchoAvatar({
    required this.isAnonymous,
    required this.isCapsule,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color iconColor;

    if (isCapsule) {
      bgColor = const Color(0xFFFFF4DB);
      iconColor = const Color(0xFFB7791F);
    } else if (isAnonymous) {
      bgColor = const Color(0xFFF3F4F6);
      iconColor = const Color(0xFF6B7280);
    } else {
      bgColor = const Color(0xFFE8F7EE);
      iconColor = const Color(0xFF1FA463);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.location_on,
            color: iconColor,
            size: 28,
          ),
        ),
        if (isCapsule)
          Positioned(
            right: -3,
            top: -3,
            child: _CornerBadge(
              icon: Icons.lock,
              color: const Color(0xFFB7791F),
            ),
          ),
        if (isAnonymous)
          Positioned(
            left: -3,
            bottom: -3,
            child: _CornerBadge(
              icon: Icons.visibility_off,
              color: const Color(0xFF6B7280),
            ),
          ),
      ],
    );
  }
}

class _CornerBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CornerBadge({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        icon,
        size: 10,
        color: Colors.white,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}