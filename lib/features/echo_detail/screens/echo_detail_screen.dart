import 'package:echo_nlu/core/components/loading_bar.dart';
import 'package:echo_nlu/core/constants/app_spacing.dart';
import 'package:echo_nlu/core/enums/echo_type.dart';
import 'package:echo_nlu/features/echo_detail/components/card_audio.dart';
import 'package:echo_nlu/features/echo_detail/controllers/echo_detail_state.dart';
import 'package:echo_nlu/features/echo_detail/models/echo_detail.dart';
import 'package:echo_nlu/features/echo_detail/models/user.dart';
import 'package:echo_nlu/features/echo_detail/providers/echo_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_waveform/just_waveform.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_size.dart';
import '../../echo/providers/create_echo_provider.dart';
import '../../echo/widgets/location_text.dart';
import '../models/comment.dart';

class EchoDetailScreen extends ConsumerStatefulWidget {
  final int echoId;
  final EchoType echoType;
  final double distance;

  const EchoDetailScreen({
    super.key,
    required this.echoId,
    required this.echoType,
    required this.distance,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EchoDetailScreenState();
}

class _EchoDetailScreenState extends ConsumerState<EchoDetailScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() => ref.read(echoDetailProvider.notifier).loadEchoDetail(widget.echoId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final echoDetailStatus = ref.watch(echoDetailProvider.select(
      (state) => state.status,
    ));

    final echoDetail = ref.watch(echoDetailProvider.select(
      (state) => state.echoDetail,
    ));

    final echoError = ref.watch(echoDetailProvider.select(
      (state) => state.errorMessage,
    ));



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
            LocationText(locationName: echoDetailStatus != EchoDetailStatus.success ?
            'Đang tải...' : echoDetail?.locationName ?? 'Đang tải...',
            isLoading: false),
          ],
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
        child: echoDetailStatus == EchoDetailStatus.loading || echoDetailStatus == EchoDetailStatus.initial
            ? LoadingBar()
            : echoDetailStatus == EchoDetailStatus.failure
            ? Center(
                child: Text(
                  echoError ?? 'Đã có lỗi xảy ra',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildContentSection(theme,echoDetail!),
                  SizedBox(height: AppSpacing.lg),
                  Expanded(child: buildComments(theme,echoDetail.comments)),
                ],
              ),
      ),
    );
  }

  Widget _buildContentSection(ThemeData theme,EchoDetail echoDetail) {
    return Container(
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
                label: Text(
                  '15',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
                avatar: Icon(Icons.remove_red_eye_outlined, color: AppColors.primaryLight),
                backgroundColor: AppColors.accent2.withOpacity(0.4),
              ),

              SizedBox(width: 8),

              Chip(
                label: Text(
                  '${widget.distance.toStringAsFixed(1)} m',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
                avatar: Icon(
                  Icons.social_distance,
                  color: AppColors.primaryLight,
                ),
                backgroundColor: AppColors.accent2.withOpacity(0.4),
              ),

              SizedBox(width: 8),

              Chip(
                label: Text(
                  echoDetail.likes.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
                avatar: Icon(Icons.favorite, color: AppColors.primaryLight),
                backgroundColor: AppColors.accent2.withOpacity(0.4),
              ),

              SizedBox(width: 8),

              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: echoDetail.isLike ? null : () {
                      ref.read(echoDetailProvider.notifier).likeEcho();
                    },
                    icon: Icon(
                    echoDetail.isLike ? Icons.favorite : Icons.favorite_outline,
                        color: Colors.redAccent,
                        size: 33
                    ),
                  ),
                ),
              )

            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            echoDetail.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            echoDetail.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryLight,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.lg),
          CardAudio(
            audio: echoDetail.media.first,
          ),
          SizedBox(height: AppSpacing.lg),
          cardUser(theme,echoDetail.user),
        ],
      ),
    );
  }

  Widget cardUser(ThemeData theme,User user) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundImage:  NetworkImage(user.avatarUrl ?? 'https://i.pravatar.cc/150?img=3'),
      ),
      title: Text(
        user.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        user.faculty ?? 'Khoa CNTT',
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.primaryLight,
        ),
      ),
      trailing: Icon(Icons.more_vert, color: AppColors.primaryLight),
    );
  }

  Widget buildComments(ThemeData theme,List<Comment> comments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bình luận ${comments.isNotEmpty ? '(${comments.length})' : ''}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                    color: Colors.lightGreen.withAlpha(60),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      comments[index].user.avatarUrl ?? 'https://i.pravatar.cc/150?img=3',
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        comments[index].user.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        comments[index].createdAt.toLocal().toString().substring(0, 16),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'Tuyệt quá đi nè',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
