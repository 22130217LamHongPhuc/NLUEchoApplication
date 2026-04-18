import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/enums/echo_type.dart';


class EchoTypeSelectorSheet extends StatelessWidget {
  final ValueChanged<EchoType> onSelected;

  const EchoTypeSelectorSheet({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      EchoTypeItemData(
        type: EchoType.audio,
        icon: Icons.mic_rounded,
        title: 'Ghi âm',
        subtitle: 'Lưu lại cảm xúc hoặc câu chuyện tại nơi này.',
      ),
      EchoTypeItemData(
        type: EchoType.image,
        icon: Icons.edit_note_rounded,
        title: 'Văn bản',
        subtitle: 'Viết vài dòng ghi chú hoặc lời nhắn.',
      ),
      EchoTypeItemData(
        type: EchoType.image,
        icon: Icons.photo_camera_rounded,
        title: 'Hình ảnh',
        subtitle: 'Lưu lại khoảnh khắc bằng ảnh.',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chọn loại Echo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chọn cách bạn muốn lưu lại ký ức tại vị trí này.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.4,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),

              ...items.map(
                    (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EchoTypeTile(
                    data: item,
                    onTap: () => onSelected(item.type),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EchoTypeItemData {
  final EchoType type;
  final IconData icon;
  final String title;
  final String subtitle;

  const EchoTypeItemData({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class EchoTypeTile extends StatelessWidget {
  final EchoTypeItemData data;
  final VoidCallback onTap;

  const EchoTypeTile({
    super.key,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  data.icon,
                  color: const Color(0xFF374151),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showEchoTypeSelectorSheet(
    BuildContext context, {
      required ValueChanged<EchoType> onSelected,
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.15),
    builder: (_) {
      return EchoTypeSelectorSheet(
        onSelected: (type) {
          Navigator.of(context).pop();
          onSelected(type);
        },
      );
    },
  );
}