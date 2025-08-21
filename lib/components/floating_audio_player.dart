// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:precious/providers/audio_player_provider.dart';
import 'package:precious/utils/config.dart';

class FloatingAudioControl extends StatelessWidget {
  const FloatingAudioControl({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);

    // Only show when audio is playing or paused, not when stopped
    if (audioProvider.currentAudioUrl == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 60, // adjust as needed
      left: MediaQuery.of(context).size.width / 2 - 60,
      child: Container(
        width: 120, // Reduced width
        height: 60,
        decoration: BoxDecoration(
          color: Config.primaryColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {
                if (audioProvider.isPlaying) {
                  audioProvider.pauseAudio();
                } else {
                  audioProvider.resumeAudio();
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                audioProvider.stopAudio();
              },
            ),
          ],
        ),
      ),
    );
  }
}
