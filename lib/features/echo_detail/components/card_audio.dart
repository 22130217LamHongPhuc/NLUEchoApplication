import 'package:echo_nlu/features/echo_detail/models/media_echo.dart';
import 'package:echo_nlu/features/echo_detail/providers/echo_audio_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class CardAudio extends ConsumerStatefulWidget {
  final EchoMedia audio;

  const CardAudio({super.key, required this.audio});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CardAudioState();
}

class _CardAudioState extends ConsumerState<CardAudio> {
  double progress = 0;

  @override
  Widget build(BuildContext context) {

    final audioState = ref.watch(echoAudioProvider);
    ThemeData theme = Theme.of(context);

    debugPrint('Audio State: isPlaying=${audioState.isPlaying}, position=${audioState.position}, duration=${audioState.duration}, currentUrl=${audioState.currentUrl}');

    final progress = audioState.duration.inMilliseconds == 0
        ? 0.0
        : audioState.position.inMilliseconds /
        audioState.duration.inMilliseconds;


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xff78DC77).withAlpha(60),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xff006E1C), Color(0xff4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if(audioState.currentUrl == null)  {
                   await ref.read(echoAudioProvider.notifier).play(
                      widget.audio.mediaUrl,
                    );
                    return;
                  }

                  await ref.read(echoAudioProvider.notifier).togglePlay();

                },
                child: Icon(
                  audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.lg),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RealWaveform(progress: progress),
                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${audioState.position.inSeconds } s',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      '${widget.audio.durationSeconds} s',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RealWaveform extends StatefulWidget {
  final double progress;

  const RealWaveform({super.key, required this.progress});

  @override
  State<RealWaveform> createState() => _RealWaveformState();
}

class _RealWaveformState extends State<RealWaveform> {

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   Future.delayed(Duration(milliseconds: 200), () {
    //     setState(() {
    //       progress += 0.01;
    //     });
    //   });
    // });
    final safeProgress = widget.progress.clamp(0.0, 1.0);

    final data = [
      30,
      45,
      70,
      55,
      35,
      80,
      60,
      40,
      65,
      50,
      75,
      45,
      30,
      55,
      68,
      42,
      65,
      50,
      75,
      45,
      30,
      55,
      68,
      42,
      65,
      50,
      75,
      45,
      30,
      55,
      68,
      42,
    ];

    return SizedBox(
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(data.length, (index) {
          final value = data[index].toDouble();

          final barProgress = index / data.length;
          final isPlayed = barProgress <= safeProgress;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: (value / 255 * 60).clamp(4, 60),
                decoration: BoxDecoration(
                  color: isPlayed
                      ? const Color(0xFF22C55E)
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
