import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    // Listen to playback events and update playback state
    _player.playbackEventStream.listen((event) {
      playbackState.add(_transformEvent(event));
    });
  }

  /// Plays the provided media URL with metadata for lock screen / notification display
  Future<void> playMedia(
      String url, String title, String artist, String imageUrl) async {
    final item = MediaItem(
      id: url,
      album: "Audio Book",
      title: title,
      artist: artist,
      artUri: Uri.parse(imageUrl),
    );

    // Adds media info for lock screen and notifications
    mediaItem.add(item);

    // Prepare and play the audio
    await _player.setUrl(url);
    _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null); // Clear the current media item when stopped
    playbackState.add(PlaybackState(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
    super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Maps JustAudio events into AudioService playback states
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      androidCompactActionIndices: const [0, 1, 3],
      processingState: _mapProcessingState(_player.processingState),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  /// Converts JustAudio ProcessingState to AudioService AudioProcessingState
  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        return AudioProcessingState.idle;
    }
  }
}
