import 'package:echo_nlu/features/echo/controllers/create_echo_controller.dart';
import 'package:echo_nlu/features/echo/providers/create_echo_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class ItemAudio extends ConsumerStatefulWidget {
  const ItemAudio({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget>  createState() => _ItemAudioState();
}

class _ItemAudioState extends ConsumerState<ItemAudio>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _opacityAnimation = Tween(
      begin: 0.5,
      end: 0.0,
    ).animate(_animationController);

    _scaleAnimation = Tween(begin: 1.0, end: 1.5).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building ItemAudio ');
    final theme = Theme.of(context);
    final audioFileState = ref.watch(
      createEchoProvider.select((s) => s.audioFile),
    );
   final notifier = ref.read(
        createEchoProvider.notifier
    );
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            isRecording
                ? AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.blueLight.withOpacity(
                                  _opacityAnimation.value,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : const SizedBox(),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,

                border: Border.all(color: AppColors.border),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isRecording = !isRecording;
                    if (isRecording) {
                      _animationController.repeat();
                      notifier.startAudioRecording();
                    } else {
                      _animationController.stop();
                      notifier.stopAudioRecording();
                    }
                  });
                },
                icon: Icon(Icons.mic),
                color: AppColors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          isRecording ? 'Đang ghi âm ' : 'Bắt đầu ghi âm',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        !isRecording && audioFileState != null ? AudioCard(
          duration: ref.read(createEchoProvider).durationInSeconds ?? 0,
        ) : const SizedBox(),
      ],
    );
  }


}

class AudioCard extends ConsumerStatefulWidget {
  final int duration;
  const AudioCard({super.key, required this.duration});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AudioCardState();
}

class _AudioCardState extends ConsumerState<AudioCard> {
   bool isPlaying = false;

  @override
  Widget build(BuildContext context) {

    final notifier = ref.read(
      createEchoProvider.notifier
    );


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                isPlaying = !isPlaying;
                if(isPlaying){
                  notifier.playAudio();
                } else {
                  notifier.pauseAudioPlayback();
                }
              });
            },
            icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bản ghi âm"),
                const SizedBox(height: 4),
                Text("${notifier.audioNoteService.duration()} giây"),
              ],
            ),
          ),
          IconButton(onPressed: () {
            notifier.refreshAudio();
          }, icon: const Icon(Icons.refresh_rounded)),
          IconButton(
            onPressed: () {
              notifier.deleteAudio();
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }



}
