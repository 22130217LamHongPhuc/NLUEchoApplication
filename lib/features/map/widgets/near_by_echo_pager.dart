import 'package:echo_nlu/core/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/echo_preview.dart';
import 'echo_preview_card.dart';

class NearbyEchoPager extends StatefulWidget {
  final List<EchoPreview> echoes;
  final bool isGuiding;
  final VoidCallback onClose;
  final void Function(EchoPreview echo) onGuide;
  final void Function(EchoPreview echo) onOpen;

  const NearbyEchoPager({
    super.key,
    required this.echoes,
    required this.isGuiding,
    required this.onClose,
    required this.onGuide,
    required this.onOpen,
  });

  @override
  State<NearbyEchoPager> createState() => _NearbyEchoPagerState();
}

class _NearbyEchoPagerState extends State<NearbyEchoPager> {
  late final PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${widget.echoes.length} Echo gần bạn',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${currentIndex + 1}/${widget.echoes.length}',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.echoes.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);

                final echo = widget.echoes[index];

              },
              itemBuilder: (context, index) {
                final echo = widget.echoes[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: EchoPreviewCard(
                    key: ValueKey('nearby_page_${echo.id}'),
                    echo: echo,
                    isGuiding: widget.isGuiding,
                    onClose: widget.onClose,
                    onGuide: (echo) => widget.onGuide(echo),
                    onOpen: widget.onOpen,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}