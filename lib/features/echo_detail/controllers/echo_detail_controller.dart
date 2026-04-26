import 'package:echo_nlu/features/echo_detail/controllers/echo_detail_state.dart';
import 'package:echo_nlu/repositories/echo_repository.dart';
import 'package:echo_nlu/services/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EchoDetailController extends AutoDisposeNotifier<EchoDetailState> {

 late final  EchoRepository echoRepository;
 late final  AudioNoteService audioNoteService;




  @override
  EchoDetailState build() {
      echoRepository = ref.read(echoRepositoryProvider);
    return const EchoDetailState();
  }

  Future<void> loadEchoDetail(int echoId) async {

    state = state.copyWith(status: EchoDetailStatus.loading);
    final response = await echoRepository.fetchEchoDetail(echoId);
    if(response.success && response.data != null) {
      state = state.copyWith(
        echoDetail: response.data,
        status: EchoDetailStatus.success,
      );
    } else {
      state = state.copyWith(status: EchoDetailStatus.failure, errorMessage: response.message);
    }

  }

 void pauseAudioPlayback() async {
   await audioNoteService.pausePlayback();
 }

 void resumeAudioPlayback() async {
   await audioNoteService.resumePlayback();
 }

 void playAudio() async {
   try {
      await audioNoteService.playAudioFromPath(state.echoDetail!.media.first.mediaUrl);
     debugPrint('Audio playback started');
   } catch (e) {
     debugPrint('Error playing audio: $e');
     state = state.copyWith(status: EchoDetailStatus.failure, errorMessage: "Không thể phát âm thanh. Vui lòng thử lại.");
   }
 }

 void stopAudioPlayback() async {
   await audioNoteService.stopPlayback();
 }

  Future<void> likeEcho() async {
   final response  = await echoRepository.likeEchoDetail(state.echoDetail!.id, 5);
    if(response.success) {
      final updatedEcho = state.echoDetail!.copyWith(
        isLiked: true,
        likeCount: state.echoDetail!.likes + 1,
      );
      state = state.copyWith(echoDetail: updatedEcho);
    } else {
      debugPrint("Error liking echo: ${response.message}");
      state = state.copyWith(errorMessage: "Không thể thích Echo. Vui lòng thử lại.");
    }
  }



}