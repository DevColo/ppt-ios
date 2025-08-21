import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? currentAudioUrl;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  AudioPlayer get audioPlayer => _audioPlayer;

  AudioPlayerProvider() {
    _audioPlayer.onPositionChanged.listen((position) {
      currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      totalDuration = duration;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      isPlaying = false;
      notifyListeners();
    });
  }

  Future<void> playAudio(String url) async {
    if (currentAudioUrl == url && isPlaying) {
      await _audioPlayer.pause();
      isPlaying = false;
    } else {
      currentAudioUrl = url;
      await _audioPlayer.play(UrlSource(url));
      isPlaying = true;
    }
    notifyListeners();
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    isPlaying = false;
    notifyListeners();
  }

  Future<void> resumeAudio() async {
    if (currentAudioUrl != null) {
      await _audioPlayer.resume();
      isPlaying = true;
      notifyListeners();
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    isPlaying = false;
    currentAudioUrl = null;
    notifyListeners();
  }
}
