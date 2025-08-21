import 'dart:io';
import 'package:flutter/material.dart';
import 'package:precious/providers/bible_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

//import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/providers/audio_player_provider.dart';
import 'package:precious/utils/config.dart';
import 'package:precious/utils/localization_service.dart';

class BibleBookAudioScreen extends StatefulWidget {
  final int bookID;
  final String title;

  const BibleBookAudioScreen({
    super.key,
    required this.bookID,
    required this.title,
  });

  @override
  State<BibleBookAudioScreen> createState() => _BibleBookAudioScreenState();
}

class _BibleBookAudioScreenState extends State<BibleBookAudioScreen> {
  bool isLoading = true;
  bool isDownloading = false;
  int? currentIndex;

  @override
  void initState() {
    super.initState();
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    try {
      final provider = Provider.of<BibleProvider>(context, listen: false);
      await provider.getBibleBookAudios(context, widget.bookID);
      setState(() => isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load chapters")),
      );
    }
  }

  Future<void> downloadChapter(
      String url, String chapterTitle, int index) async {
    setState(() => isDownloading = true);

    try {
      final response = await http.get(Uri.parse(url));
      final directory = await getApplicationDocumentsDirectory();
      final filename = '${widget.title}_$chapterTitle.mp3';
      final file = File('${directory.path}/$filename');

      await file.writeAsBytes(response.bodyBytes);

      Provider.of<BibleProvider>(context, listen: false)
          .refreshDownloadedFiles();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$filename downloaded!')),
      );
    } catch (e) {
      debugPrint('Error downloading chapter: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download failed')),
      );
    } finally {
      setState(() => isDownloading = false);
    }
  }

  Widget buildChapterItem(int index, Map<String, dynamic> chapter) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);
    final audioLink = chapter['audio_link'];
    final isPlayingNow =
        audioProvider.currentAudioUrl == audioLink && audioProvider.isPlaying;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4.0),
      decoration: BoxDecoration(
        color: isPlayingNow ? Config.primaryColor : Config.whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
        leading: Icon(
          Icons.headphones,
          color: isPlayingNow ? Config.whiteColor : Config.greyColor,
          size: 18.0,
        ),
        title: Text(
          chapter['title'],
          style: TextStyle(
            fontFamily: 'Montserrat-SemiBold',
            color: isPlayingNow ? Config.whiteColor : Config.darkColor,
            fontSize: 12.0,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.download,
                color: isPlayingNow ? Config.whiteColor : Config.darkColor,
                size: 18.0,
              ),
              onPressed: () =>
                  downloadChapter(audioLink, chapter['title'], index),
            ),
            IconButton(
              icon: Icon(
                Icons.share,
                color: isPlayingNow ? Config.whiteColor : Config.darkColor,
                size: 18.0,
              ),
              onPressed: () => Share.share(audioLink),
            ),
          ],
        ),
        onTap: () {
          audioProvider.playAudio(audioLink);
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  Widget buildChapterList() {
    final chapters = Provider.of<BibleProvider>(context).audios;

    if (chapters.isEmpty) {
      return Center(child: Text(LocalizationService().translate('noData')));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        return buildChapterItem(index, chapters[index]);
      },
    );
  }

  Widget buildBottomPlayerControls() {
    final audioProvider = Provider.of<AudioPlayerProvider>(context);

    if (audioProvider.currentAudioUrl == null) return const SizedBox();

    final currentPosition = audioProvider.currentPosition;
    final totalDuration = audioProvider.totalDuration;

    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Config.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: currentPosition.inMilliseconds.toDouble(),
            min: 0,
            max: totalDuration.inMilliseconds > 0
                ? totalDuration.inMilliseconds.toDouble()
                : 1,
            activeColor: Config.primaryColor,
            onChanged: (value) {
              audioProvider.audioPlayer
                  .seek(Duration(milliseconds: value.toInt()));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatDuration(currentPosition),
                    style: const TextStyle(fontSize: 12)),
                Text(formatDuration(totalDuration),
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // IconButton(
              //   icon: const Icon(
              //     Icons.share,
              //     color: Config.primaryColor,
              //   ),
              //   onPressed: () {
              //     if (audioProvider.currentAudioUrl != null) {
              //       Share.share(audioProvider.currentAudioUrl!);
              //     }
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 32),
                color: Config.primaryColor,
                onPressed: () {
                  if (currentIndex != null && currentIndex! > 0) {
                    final chapters =
                        Provider.of<BibleProvider>(context, listen: false)
                            .audios;
                    final previousAudioLink =
                        chapters[currentIndex! - 1]['audio_link'];
                    audioProvider.playAudio(previousAudioLink);
                    setState(() {
                      currentIndex = currentIndex! - 1;
                    });
                  }
                },
              ),
              GestureDetector(
                onTap: () {
                  if (audioProvider.isPlaying) {
                    audioProvider.pauseAudio();
                  } else {
                    audioProvider.resumeAudio();
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Config.primaryColor),
                  child: Icon(
                    audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 32),
                color: Config.primaryColor,
                onPressed: () {
                  final chapters =
                      Provider.of<BibleProvider>(context, listen: false).audios;
                  if (currentIndex != null &&
                      currentIndex! < chapters.length - 1) {
                    final nextAudioLink =
                        chapters[currentIndex! + 1]['audio_link'];
                    audioProvider.playAudio(nextAudioLink);
                    setState(() {
                      currentIndex = currentIndex! + 1;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Config.greyColor,
      appBar: AppBar(
        backgroundColor: Config.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Config.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Config.darkColor,
              fontFamily: 'Montserrat-SemiBold',
              fontSize: 14),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Config.primaryColor))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildChapterList(),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false, // we only care about bottom padding
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: buildBottomPlayerControls(),
                  ),
                ),
              ],
            ),
    );
  }
}
