import 'package:echo_nlu/features/echo_detail/providers/echo_detail_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/echo_repository.dart';
import '../models/comment.dart';




class EchoCommentState {
  final bool isLoadingComments;
  final bool isAddingComment;
  final List<Comment> comments;
  final String? errorMessage;

  EchoCommentState({
      this.isLoadingComments = false,
    this.isAddingComment = false,
    this.errorMessage,
      this.comments = const [],
  });

  EchoCommentState copyWith({
      bool? isLoadingComments,
    bool? isAddingComment,
    String? errorMessage,
    bool clearErrorMessage = false,
    List<Comment> comments = const [],
  }) {
    return EchoCommentState(
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      isAddingComment: isAddingComment ?? this.isAddingComment,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      comments: comments.isEmpty ? this.comments : comments,
    );
  }
}


class EchoCommentController extends Notifier<EchoCommentState> {
  late final EchoRepository echoRepository;



  EchoCommentController();


  @override
  EchoCommentState build() {
    echoRepository = ref.read(echoRepositoryProvider);
    return EchoCommentState();
  }



  Future<void> fetchComments(int echoId) async {
    if(state.comments.isNotEmpty) return;
    state = state.copyWith(isLoadingComments: true, clearErrorMessage: true);
    final response = await echoRepository.fetchComments(echoId);
    state = state.copyWith(comments: response.data ?? []);
  }
  Future<void> addComment(int echoId, String content) async {
    state = state.copyWith(isAddingComment: true, clearErrorMessage: true);
    final response = await echoRepository.addComment(echoId, 5, content);
     state = state.copyWith(isAddingComment: false, comments: [...state.comments, response.data!]);
     ref.read(echoDetailProvider.notifier).incrementCommentCount();
  }


}