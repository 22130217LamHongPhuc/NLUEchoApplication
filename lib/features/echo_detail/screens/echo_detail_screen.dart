import 'package:echo_nlu/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_waveform/just_waveform.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_size.dart';
import '../../echo/providers/create_echo_provider.dart';
import '../../echo/widgets/location_text.dart';

class EchoDetailScreen extends ConsumerStatefulWidget {
  final int echoId;

  const EchoDetailScreen({super.key, required this.echoId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EchoDetailScreenState();
}

class _EchoDetailScreenState extends ConsumerState<EchoDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.accent,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        actions: [
          Center(
            child: Icon(Icons.location_on_outlined, color: AppColors.primary),
          ),
        ],
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết Echo',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: AppTextSize.lg,
                fontWeight: FontWeight.bold,
              ),
            ),
            LocationText(locationName: 'Địa điểm cụ thể', isLoading: false),
          ],
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             _buildContentSection(theme)
          ],
        ),
      )
    );
  }

  Widget _buildContentSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.0),
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text('Kén Capsule',style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark)),
                  avatar: Icon(Icons.history,color: AppColors.primaryLight),
                  backgroundColor: AppColors.accent2.withOpacity(0.4),
                ),

                SizedBox(width: 8,),

                Chip(
                  label: Text('10 m',style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark)),
                  avatar: Icon(Icons.social_distance,color: AppColors.primaryLight),
                  backgroundColor: AppColors.accent2.withOpacity(0.4),
                ),

                Chip(
                  label: Text('2',style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark)),
                  avatar: Icon(Icons.favorite,color: AppColors.primaryLight),
                  backgroundColor: AppColors.accent2.withOpacity(0.4),
                )
              ],
            ),
              SizedBox(height: AppSpacing.lg,),
            Text('Tiếng ve kêu mùa hè',style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold
            )),
            SizedBox(height: AppSpacing.lg,),
            Text('Âm thanh quen thuộc mỗi khi hè về tại giảng đường Nông Lâm',style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryLight
            ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.lg,),
            cardAudio(theme),
            SizedBox(height: AppSpacing.lg,),
            cardUser(theme)


          ],
        ),
      ),
    );
  }

  Widget cardAudio(ThemeData theme) {
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
                colors: [
                  Color(0xff006E1C),
                  Color(0xff4CAF50),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            ),
            child: Center(child: const Icon(Icons.play_arrow, color: Colors.white, size: 32)),

          ),
          SizedBox(width: AppSpacing.lg,),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RealWaveform(progress: 0.1),
                SizedBox(height: AppSpacing.sm,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0:30', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryDark)),
                    Text('3:00', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryDark)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget cardUser(ThemeData theme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
      ),
      title: Text('Nguyễn Văn A', style: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.primaryDark,
        fontWeight: FontWeight.bold
      )),
      subtitle: Text('Khoa Kinh Tế', style: theme.textTheme.bodySmall?.copyWith(
        color: AppColors.primaryLight
      ),
      ),
      trailing: Icon(Icons.more_vert, color: AppColors.primaryLight),
    );
  }



}
class RealWaveform extends StatefulWidget {
  final double progress;

  const RealWaveform({
    super.key,
    required this.progress,
  });

  @override
  State<RealWaveform> createState() => _RealWaveformState();
}

class _RealWaveformState extends State<RealWaveform> {

  double progress = 0.0;
  @override
  Widget build(BuildContext context) {
    setState(() {
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          progress += 0.01;
        });
      });
    });
    final safeProgress = progress.clamp(0.0, 1.0);


    final data = [
      30, 45, 70, 55, 35, 80, 60, 40,
      65, 50, 75, 45, 30, 55, 68, 42,
      65, 50, 75, 45, 30, 55, 68, 42,

      65, 50, 75, 45, 30, 55, 68, 42,

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