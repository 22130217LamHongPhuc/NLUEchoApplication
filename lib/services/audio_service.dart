import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';

class AudioNoteService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();


  String? _lastFilePath;

  String? get lastFilePath => _lastFilePath;

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();

    return status.isGranted;
  }

  Future<void> startRecording() async {


    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/echo_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(),
      path: path,
    );

    _lastFilePath = path;
  }

  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    if (path != null) {
      _lastFilePath = path;
    }
    await _player.setFilePath(path!);
    await _player.setLoopMode(LoopMode.all);

    return path;
  }



  Future<void> playLastRecording() async {
    final path = _lastFilePath;
    if (path == null || !File(path).existsSync()) {
      throw Exception('Chưa có file ghi âm để phát');
    }
    await stopPlayback();

    await _player.setFilePath(path);
    await _player.play();
  }

  Future<void> playAudioFromPath(String path) async {
    await stopPlayback();
    await _player.setFilePath(path);
    await _player.play();
  }

  Future<void> playAudio() async {
    final path = _lastFilePath;
    if (path == null || !File(path).existsSync()) {
      throw Exception('Chưa có file ghi âm để phát');
    }

    await _player.play();
  }

  Future<void> resumePlayback() async {
    await _player.play();
  }

  Future<void> pausePlayback() async {
    await _player.pause();
  }

  Future<void> stopPlayback() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _recorder.dispose();
  }

  int duration()  {

    return _player.duration != null ? _player.duration!.inSeconds : 0;
  }


  Future<void> deleteAudio() async {

    if (_lastFilePath != null) {
      final file = File(_lastFilePath!);
      if (file.existsSync()) {
        file.deleteSync();
        await stopPlayback();

      }
      _lastFilePath = null;
    }
  }

  Future<void> refreshAudio() async {
   await stopPlayback();
   await playAudio();

  }

}

