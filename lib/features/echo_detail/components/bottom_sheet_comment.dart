import 'package:echo_nlu/core/components/loading_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../models/comment.dart';
import '../providers/echo_detail_provider.dart';

  Future<void> openCommentSheet(BuildContext context, {required int echoId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: Duration(milliseconds: 300),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        final keyboardHeight = MediaQuery.of(sheetContext).viewInsets.bottom;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.7,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Material(
                color: Colors.white,
                child: ListComment(
                  echoId: echoId,
                ),
              ),
            ),
          ),
        );
      },
    );
  }


class ListComment extends ConsumerStatefulWidget {
  final int echoId;

  const ListComment({super.key, required this.echoId});


  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ListCommentState();
}

class _ListCommentState extends ConsumerState<ListComment> {


  late final TextEditingController controllerTextField;


  @override
  void initState() {
    super.initState();
    controllerTextField = TextEditingController();
    Future.microtask(() =>
        ref.read(echoCommentsProvider.notifier).fetchComments(widget.echoId));
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(echoCommentsProvider);
    final comments = state.comments;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      child: Column(
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
                        comments[index].user.avatarUrl ??
                            'https://i.pravatar.cc/150?img=3',
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
                          comments[index].createdAt
                              .toLocal()
                              .toString()
                              .substring(0, 16),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      comments[index].content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          TextField(
              controller: controllerTextField,
              decoration: InputDecoration(
                  hintText: 'Viết bình luận...',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.grey.withAlpha(60),
                      width: 1,
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1,
                       )

                  ),
                  suffixIcon: ValueListenableBuilder(
                      valueListenable: controllerTextField,
                      builder: (context, value, child) {
                        final isEmpty = value.text
                            .trim()
                            .isEmpty;
                        final isSubmitting = state.isAddingComment;
                         if(isSubmitting) {
                           return SizedBox(
                             width: 24,
                             height: 24,
                             child: CircularProgressIndicator(
                               strokeWidth: 2,
                               color: AppColors.primary,
                             ),
                           );
                         }

                        return IconButton(
                          onPressed: isEmpty ? null : onSend,
                          icon: Icon(
                            Icons.send_rounded,
                            color: isEmpty ? AppColors.primary.withAlpha(70) : AppColors.primary,
                          ),
                        );
                      }

                  )
              )
          )
        ],
      ),
    );
  }


  void onSend() {
    final content = controllerTextField.text.trim();
    if (content.isEmpty) return;

    ref.read(echoCommentsProvider.notifier).addComment(
        widget.echoId,
        content
    );
    controllerTextField.clear();
  }
}
