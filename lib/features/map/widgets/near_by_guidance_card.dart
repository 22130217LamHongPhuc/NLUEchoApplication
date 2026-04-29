import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'glass_panel.dart';

class NearbyGuidanceCard extends StatelessWidget {
  final int nearbyCount;
  final String title;
  final String distanceText;
  final String hintText;
  final VoidCallback onGoTo;
  final VoidCallback onOpenList;
  final VoidCallback onClose;

  const NearbyGuidanceCard({
    super.key,
    required this.nearbyCount,
    required this.title,
    required this.distanceText,
    required this.hintText,
    required this.onGoTo,
    required this.onOpenList,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Có $nearbyCount Echo gần bạn',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(onPressed: onClose, icon: Icon(Icons.close,color:Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ' Echo gần nhất cách bạn $distanceText',
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hintText,
            style: const TextStyle(
              color: Color(0xFF3AF89C),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PrimaryGlowButton(
                  label: 'Đi tới',
                  icon: Icons.near_me_rounded,
                  onTap: onGoTo,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyDiscoveryCard extends StatelessWidget {
  final VoidCallback onExploreCampus;

  const EmptyDiscoveryCard({super.key, required this.onExploreCampus});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chưa có Echo nào thật gần bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử di chuyển đến khu vực trung tâm NLU hoặc khám phá những nơi có nhiều ký ức hơn.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          PrimaryGlowButton(
            label: 'Về trung tâm NLU',
            icon: Icons.school_rounded,
            onTap: onExploreCampus,
          ),
        ],
      ),
    );
  }
}
