// ignore_for_file: deprecated_member_use

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:precious/utils/config.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String filePath;

  const AudioPlayerScreen({super.key, required this.filePath});

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = true;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  double sliderValue = 0.0;
  late AnimationController _animationController;
  double playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _initAudioPlayer();
  }

  void _initAudioPlayer() async {
    // Set up listeners
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          currentPosition = position;
          if (totalDuration.inMilliseconds > 0) {
            sliderValue = position.inMilliseconds.toDouble();
          }
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          totalDuration = duration;
          isLoading = false;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          currentPosition = totalDuration;
          _animationController.reverse();
        });
      }
    });

    // Preload the audio file
    await _audioPlayer.setSourceDeviceFile(widget.filePath);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> togglePlay() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
        _animationController.reverse();
      } else {
        await _audioPlayer.resume();
        _animationController.forward();
      }
      setState(() {
        isPlaying = !isPlaying;
      });
    } catch (e) {
      print("Error toggling playback: $e");
    }
  }

  Future<void> seekBackward() async {
    final newPosition = Duration(
      milliseconds: (currentPosition.inMilliseconds - 10000)
          .clamp(0, totalDuration.inMilliseconds),
    );
    await _audioPlayer.seek(newPosition);
  }

  Future<void> seekForward() async {
    final newPosition = Duration(
      milliseconds: (currentPosition.inMilliseconds + 10000)
          .clamp(0, totalDuration.inMilliseconds),
    );
    await _audioPlayer.seek(newPosition);
  }

  Future<void> changePlaybackSpeed() async {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    int currentIndex = speeds.indexOf(playbackSpeed);
    int nextIndex = (currentIndex + 1) % speeds.length;

    setState(() {
      playbackSpeed = speeds[nextIndex];
    });

    await _audioPlayer.setPlaybackRate(playbackSpeed);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? "$hours:$minutes:$seconds"
        : "$minutes:$seconds";
  }

  String getFileName() {
    final fileName = widget.filePath.split('/').last;
    return fileName.replaceAll('.mp3', '').replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final fileName = getFileName();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Config.darkColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Config.primaryColor))
          : Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Album art or audio visualization
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Config.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.music_note,
                            size: 80,
                            color: Config.primaryColor.withOpacity(0.7),
                          ),
                        ),
                      ),

                      // Title and artist
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              fileName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat-Bold',
                                color: Config.darkColor,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Player controls
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Playback speed button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: changePlaybackSpeed,
                            icon: const Icon(Icons.speed, size: 18),
                            label: Text(
                              '${playbackSpeed}x',
                              style: const TextStyle(
                                fontFamily: 'Montserrat-Medium',
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Config.primaryColor,
                              backgroundColor:
                                  Config.primaryColor.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Progress slider
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          activeTrackColor: Config.primaryColor,
                          inactiveTrackColor:
                              Config.primaryColor.withOpacity(0.2),
                          thumbColor: Config.primaryColor,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 14),
                          overlayColor: Config.primaryColor.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: sliderValue.clamp(
                              0,
                              totalDuration.inMilliseconds.toDouble() > 0
                                  ? totalDuration.inMilliseconds.toDouble()
                                  : 1),
                          min: 0,
                          max: totalDuration.inMilliseconds.toDouble() > 0
                              ? totalDuration.inMilliseconds.toDouble()
                              : 1,
                          onChanged: (value) {
                            setState(() {
                              sliderValue = value;
                            });
                          },
                          onChangeEnd: (value) {
                            _audioPlayer
                                .seek(Duration(milliseconds: value.toInt()));
                          },
                        ),
                      ),

                      // Time indicators
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDuration(currentPosition),
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Montserrat-Regular',
                                color: Config.darkColor.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              formatDuration(totalDuration),
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Montserrat-Regular',
                                color: Config.darkColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Skip backward button
                          IconButton(
                            icon: const Icon(Icons.replay_10, size: 32),
                            color: Config.darkColor,
                            onPressed: seekBackward,
                          ),

                          // Play/Pause button
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Config.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Config.primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: AnimatedIcon(
                                icon: AnimatedIcons.play_pause,
                                progress: _animationController,
                                color: Colors.white,
                                size: 38,
                              ),
                              onPressed: togglePlay,
                            ),
                          ),

                          // Skip forward button
                          IconButton(
                            icon: const Icon(Icons.forward_10, size: 32),
                            color: Config.darkColor,
                            onPressed: seekForward,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
