// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precious/providers/bible_verses_provider.dart';
import 'package:precious/screens/bible_verses_screen.dart';
import 'package:precious/utils/config.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class BibleSermonScreen extends StatefulWidget {
  final String title;
  final String videoLink;

  const BibleSermonScreen({
    super.key,
    required this.title,
    required this.videoLink,
  });

  @override
  State<BibleSermonScreen> createState() => _BibleSermonScreenState();
}

class _BibleSermonScreenState extends State<BibleSermonScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _isControlsVisible = true;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.videoLink)
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
      });

    _controller.addListener(() {
      setState(() {});
    });

    fetchVideos();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shareVideoLink() {
    try {
      Share.share(
          'Shared from Precious Present Truth - Mobile App: ${widget.videoLink}');
    } catch (e) {
      debugPrint('Error sharing video link: $e');
    }
  }

  void downloadVideo() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required!')),
          );
          return;
        }
      }

      final dir = await getExternalStorageDirectory();

      if (dir == null) {
        Navigator.of(context).pop();
        debugPrint('Storage directory not found');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to access storage.')),
        );
        return;
      }

      final uri = Uri.parse(widget.videoLink);
      final fileName = uri.pathSegments.last;

      await FlutterDownloader.enqueue(
        url: widget.videoLink,
        savedDir: dir.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );

      debugPrint('Downloading: $fileName');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading: $fileName')),
      );
    } catch (e) {
      debugPrint('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> fetchVideos() async {
    await Provider.of<BibleVersesProvider>(context).verses;
  }

  Widget buildVideoPlayer(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isControlsVisible = !_isControlsVisible;
        });
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),

          // Controls
          if (_isControlsVisible) buildControls(),

          // Progress Bar
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
    );
  }

  Widget buildControls() {
    final isMuted = _controller.value.volume == 0;
    final duration = _controller.value.duration;
    final position = _controller.value.position;

    return Container(
      color: Colors.black26,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Play / Pause
          IconButton(
            iconSize: 50,
            color: Colors.white,
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    _controller.setVolume(isMuted ? 1 : 0);
                  });
                },
              ),
              Text(
                '${formatDuration(position)} / ${formatDuration(duration)}',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                color: Colors.white,
                onPressed: () {
                  _goFullScreen(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _goFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final verses = Provider.of<BibleVersesProvider>(context).verses;

    if (isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return true;
      },
      child: Scaffold(
        appBar: isLandscape
            ? null
            : AppBar(
                backgroundColor: Config.primaryColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Config.whiteColor,
                  ),
                  onPressed: () async {
                    await SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                    ]);
                    await SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.edgeToEdge);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BibleVersesScreen(),
                      ),
                    );
                  },
                ),
                title: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Montserrat-SemiBold',
                    color: Config.whiteColor,
                  ),
                ),
                actions: [
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.more_vert, color: Config.whiteColor),
                    onSelected: (value) {
                      if (value == 1) {
                        shareVideoLink();
                      } else if (value == 2) {
                        downloadVideo();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: ListTile(
                          leading: const Icon(Icons.share),
                          title: Text(LocalizationService().translate('share')),
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: ListTile(
                          leading: const Icon(Icons.download),
                          title:
                              Text(LocalizationService().translate('download')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        backgroundColor: Config.greyColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isLoading) const SizedBox(height: 10.0),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 25.0),
                      child: buildVideoPlayer(context),
                    ),

                  const SizedBox(height: 10.0),

                  // Any additional widgets below the video
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: verses.isEmpty
                        ? Center(
                            child:
                                Text(LocalizationService().translate('noData')),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: verses.length,
                            itemBuilder: (context, index) {
                              final video = verses[index];
                              return videoCard(
                                  video['title'], video['video_link']);
                            },
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Optional: FloatingAudioPlayer (if you want to keep it fixed, move it outside the scroll)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget videoCard(String title, String videoLink) {
    bool isCurrentlyPlaying = widget.title == title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: () async {
          if (_controller.value.isPlaying) {
            _controller.pause();
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BibleSermonScreen(
                title: title,
                videoLink: videoLink,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isCurrentlyPlaying ? Config.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding:
              const EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 8.0),
          child: Row(
            children: [
              Container(
                height: 50,
              ),
              const SizedBox(width: 15.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 190,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isCurrentlyPlaying
                            ? Config.whiteColor
                            : const Color.fromARGB(255, 0, 0, 0),
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.play_circle_fill,
                color: isCurrentlyPlaying
                    ? Config.whiteColor
                    : Config.primaryColor,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          Navigator.pop(context);
        },
        child: const Icon(Icons.fullscreen_exit),
      ),
    );
  }
}
