import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/providers/audio_player_provider.dart';
import 'package:precious/screens/pdf_book_view.dart';
import 'package:precious/utils/config.dart';
import 'package:precious/utils/localization_service.dart';

class AudioScreen extends StatefulWidget {
  final int bookID;
  final String title;
  final String description;
  final String author;
  final String imageUrl;
  final String pdfUrl;

  const AudioScreen({
    super.key,
    required this.bookID,
    required this.title,
    required this.description,
    required this.author,
    required this.imageUrl,
    required this.pdfUrl,
  });

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  bool isLoading = true;
  bool isDownloading = false;
  int? currentIndex;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    try {
      final provider = Provider.of<AudioBooksProvider>(context, listen: false);
      await provider.getBooks(context, widget.bookID);
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint("Error fetching chapters: $e");
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

      Provider.of<AudioBooksProvider>(context, listen: false)
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

  Widget buildBookInfoSection() {
    bool hasLongDescription = widget.description.split(' ').length > 20;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(widget.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat-SemiBold',
                      color: Config.darkColor)),
              const SizedBox(height: 4),
              Text(widget.author,
                  style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Montserrat-Regular',
                      color: Config.darkColor)),
              const SizedBox(height: 10),
              Text(
                widget.description,
                maxLines: _isExpanded ? null : 5,
                overflow:
                    _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Montserrat-Regular',
                    color: Config.darkColor),
              ),
              if (hasLongDescription)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      color: Config.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
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
          '${LocalizationService().translate('chapter')} ${chapter['chapter']}',
          style: TextStyle(
            fontFamily: 'Montserrat-SemiBold',
            color: isPlayingNow ? Config.whiteColor : Config.darkColor,
            fontSize: 14.0,
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
                  downloadChapter(audioLink, chapter['chapter'], index),
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
    final chapters = Provider.of<AudioBooksProvider>(context).books;

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
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 20.0,
        top: 5.0,
      ),
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
                        Provider.of<AudioBooksProvider>(context, listen: false)
                            .books;
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
                      Provider.of<AudioBooksProvider>(context, listen: false)
                          .books;
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
        title: Text(widget.title,
            style: const TextStyle(
                color: Config.darkColor,
                fontFamily: 'Montserrat-SemiBold',
                fontSize: 14)),
        actions: [
          IconButton(
            icon: const Icon(Icons.book, color: Config.primaryColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      PDFBookView(title: widget.title, pdfUrl: widget.pdfUrl)),
            ),
          ),
        ],
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
                        buildBookInfoSection(),
                        const SizedBox(height: 16),
                        // Optional text and spacing here...
                        buildChapterList(),
                      ],
                    ),
                  ),
                ),

                // Wrapping player controls in SafeArea
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
