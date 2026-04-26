import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer player = AudioPlayer();
  String? audioUrl;

  Future<void> setAssets(String url) async {
    audioUrl = url;
    await player.setUrl(url);
  }

  Future<void> play() async {
    if (audioUrl == null) {
      return;
    }
    await player.play();
  }

  Future<void> togglePlay() async {

    if (audioUrl == null) {
      return;
    }
    if (player.processingState == ProcessingState.completed) {
      await player.seek(Duration(seconds: 0));
      await player.play();
      return;
    }

    debugPrint("Current player state: ${player.playerState}");
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
    debugPrint("After player state: ${player.playerState}");

  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> dispose() async {
    await player.dispose();
  }

  Stream<Duration> get positionStream => player.positionStream;

  Stream<Duration?> get durationStream => player.durationStream;
}

class EchoAudioState {
  final String? currentUrl;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const EchoAudioState({
    this.currentUrl,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  EchoAudioState copyWith({
    String? currentUrl,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return EchoAudioState(
      currentUrl: currentUrl ?? this.currentUrl,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class EchoAudioController extends AutoDisposeNotifier<EchoAudioState> {
  late final AudioService audioService;

  EchoAudioController() {
    audioService = AudioService();
  }

  @override
  EchoAudioState build() {
    audioService.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    audioService.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    audioService.player.playerStateStream.listen((playerState) {
      final isCompleted =
          playerState.processingState == ProcessingState.completed;
      if (isCompleted) {
        debugPrint("Audio playback completed");
        state = state.copyWith(
          isPlaying: false,
          position: Duration(seconds: 0),
        );
      }
    });

    ref.onDispose(() {
      audioService.dispose();
    });
    return const EchoAudioState();
  }

  Future<void> play(String url) async {
    debugPrint("Playing audio from URL: $url");

    if (state.currentUrl != url) {
      await audioService.stop();
    }
    await audioService.setAssets(url);
    audioService.play();
    debugPrint("Audio playback started");
    state = state.copyWith(
      currentUrl: url,
      isPlaying: audioService.player.playing,
    );
  }

  Future<void> togglePlay() async {
    debugPrint("Toggling play/pause for) audio: ${state.currentUrl}");
     audioService.togglePlay();
    debugPrint("Audio playback toggled. Now playing: ${audioService.player.playerState}");
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void updatePosition(Duration position) {
    state = state.copyWith(position: position);
  }

  void updateDuration(Duration duration) {
    state = state.copyWith(duration: duration);
  }

  void stop() {
    state = const EchoAudioState();
  }
}
