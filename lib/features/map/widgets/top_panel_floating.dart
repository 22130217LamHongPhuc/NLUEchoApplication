import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controllers/map_home_state.dart';

class TopFloatingPanel extends StatelessWidget {
  final String statusText;
  final NluAccessState accessState;
  final List<MapFilterItem> filters;
  final int selectedIndex;
  final ValueChanged<int> onFilterSelected;


  const TopFloatingPanel({
    required this.statusText,
    required this.accessState,
    required this.filters,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  Color _statusColor() {
    switch (accessState) {
      case NluAccessState.insideNLU:
        return const Color(0xFF6EE7B7);
      case NluAccessState.nearNLU:
        return const Color(0xFFFBBF24);
      case NluAccessState.outsideNLU:
        return const Color(0xFFFDA4AF);
    }
  }

  IconData _statusIcon() {
    switch (accessState) {
      case NluAccessState.insideNLU:
        return Icons.location_on_rounded;
      case NluAccessState.nearNLU:
        return Icons.near_me_rounded;
      case NluAccessState.outsideNLU:
        return Icons.public_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(_statusIcon(), color: statusColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final item = filters[index];
                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () => onFilterSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8AB7F8)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF7DD3FC).withOpacity(0.7)
                            : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.82),
                        fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: filters.length,
            ),
          ),
        ],
      ),
    );
  }
}

class MapFilterItem {
  final int id;
  final String label;
  const MapFilterItem({required this.id, required this.label});

}