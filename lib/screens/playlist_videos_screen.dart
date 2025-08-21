import 'package:flutter/material.dart';
import 'package:precious/components/floating_audio_player.dart';
import 'package:precious/providers/sermons_provider.dart';
import 'package:precious/screens/video_screen.dart';
import 'package:precious/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PlayListVideosScreen extends StatefulWidget {
  final String title;
  final int playListId;

  const PlayListVideosScreen({
    super.key,
    required this.title,
    required this.playListId,
  });

  @override
  State<PlayListVideosScreen> createState() => _PlayListVideosScreenState();
}

class _PlayListVideosScreenState extends State<PlayListVideosScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVideos();
    _loadData();
  }

  Future<void> fetchVideos() async {
    await Provider.of<SermonsProvider>(context, listen: false)
        .getVideos(context, widget.playListId);
  }

  // Simulate data fetching and update the loading state
  Future<void> _loadData() async {
    // isLoading = true;
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayList = Provider.of<SermonsProvider>(context).videos;

    return Scaffold(
      backgroundColor: Config.greyColor,
      appBar: AppBar(
        backgroundColor: Config.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Config.darkColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Montserrat-SemiBold',
            color: Config.darkColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5, // Placeholder count
                    itemBuilder: (context, index) => shimmerVideoPlayList(),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: videoPlayList.length,
                    itemBuilder: (context, index) {
                      final video = videoPlayList[index];
                      return videoCard(
                        video['title'],
                        video['video_link'],
                        widget.playListId,
                      );
                    },
                  ),
            FloatingAudioControl(),
          ],
        ),
      ),
    );
  }

  Widget shimmerVideoPlayList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              height: 70,
            ),
            const SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 12,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 5.0),
                Container(
                  width: 80,
                  height: 12,
                  color: Colors.grey[300],
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.play_circle_fill,
              color: Colors.grey, // Adjusted for shimmer
              size: 25.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget videoCard(String title, String videoLink, int playListID) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(
                title: title,
                videoLink: videoLink,
                playListID: playListID,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding:
              const EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 8.0),
          child: Row(
            children: [
              Container(
                height: 50,
              ),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 230,
                    //height: 40.0,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.play_circle_fill,
                color: Config.primaryColor,
                size: 25.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
