import 'package:echo_nlu/features/echo_detail/controllers/echo_detail_state.dart';
import 'package:echo_nlu/features/echo_detail/providers/echo_detail_provider.dart';
import 'package:echo_nlu/repositories/echo_repository.dart';
import 'package:echo_nlu/services/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';

class EchoDetailController extends AutoDisposeNotifier<EchoDetailState> {

  late final EchoRepository echoRepository;


  @override
  EchoDetailState build() {
    echoRepository = ref.read(echoRepositoryProvider);
    ref.onDispose((){
      ref.invalidate(echoCommentsProvider);
    });
    return const EchoDetailState();
  }




  Future<void> loadEchoDetail(int echoId) async {


    state = state.copyWith(status: EchoDetailStatus.loading);
    final response = await echoRepository.fetchEchoDetail(echoId);
    if (response.success && response.data != null) {
      state = state.copyWith(
        echoDetail: response.data,
        status: EchoDetailStatus.success,
      );
    } else {

      state = state.copyWith(
          status: EchoDetailStatus.failure, errorMessage: response.message);
    }
  }



  Future<void> likeEcho() async {
    final response = await echoRepository.likeEchoDetail(
        state.echoDetail!.id, 5);
    if (response.success) {
      final updatedEcho = state.echoDetail!.copyWith(
        isLike: true,
        likes: state.echoDetail!.likes + 1,
      );
      state = state.copyWith(echoDetail: updatedEcho);
    } else {
      debugPrint("Error liking echo: ${response.message}");
      state = state.copyWith(
          errorMessage: "Không thể thích Echo. Vui lòng thử lại.");
    }
  }

  void incrementCommentCount() {
    final updatedEcho = state.echoDetail!.copyWith(
      commentsCount: state.echoDetail!.commentsCount + 1,
    );
    state = state.copyWith(echoDetail: updatedEcho);
  }




}