import 'package:echo_nlu/features/echo_detail/controllers/echo_audio_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final echoAudioProvider = NotifierProvider.autoDispose<EchoAudioController, EchoAudioState>(
    () => EchoAudioController()
);