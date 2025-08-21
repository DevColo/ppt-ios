import 'package:flutter/material.dart';
import 'package:precious/providers/sermons_provider.dart';
import 'package:precious/screens/playlist_videos_screen.dart';
import 'package:precious/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class VideoCollectionScreen extends StatefulWidget {
  final int pastorId;
  final String pastorName;
  final String pastorBio;
  final String imageUrl;

  const VideoCollectionScreen({
    super.key,
    required this.pastorId,
    required this.pastorName,
    required this.pastorBio,
    required this.imageUrl,
  });

  @override
  _VideoCollectionScreenState createState() => _VideoCollectionScreenState();
}

class _VideoCollectionScreenState extends State<VideoCollectionScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSermons();
    _loadData();
  }

  Future<void> fetchSermons() async {
    await Provider.of<SermonsProvider>(context, listen: false)
        .getSermons(context, widget.pastorId);
  }

  // Simulate data fetching and update the loading state
  Future<void> _loadData() async {
    // isLoading = true;
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  // String formatDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, '0');
  //   final minutes = twoDigits(duration.inMinutes);
  //   final seconds = twoDigits(duration.inSeconds % 60);
  //   return "$minutes:$seconds";
  // }

  @override
  Widget build(BuildContext context) {
    final videoPlayList = Provider.of<SermonsProvider>(context).sermons;

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Container with White Background
            Container(
              decoration: BoxDecoration(
                color: Config.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(widget.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pastorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Montserrat-SemiBold',
                              color: Config.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  widget.pastorBio.isNotEmpty
                      ? Column(
                          children: [
                            const SizedBox(height: 20),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.pastorBio,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Config.whiteColor,
                                      fontFamily: 'Montserrat-Regular',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                      return videoPlayListCard(
                        video['title'],
                        video['id'],
                      );
                    },
                  ),
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
        child: Padding(
          padding:
              const EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 8.0),
          child: Row(
            children: [
              Container(
                height: 50,
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
                Icons.arrow_forward_ios,
                color: Colors.grey, // Adjusted for shimmer
                size: 25.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget videoPlayListCard(String title, int playListId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayListVideosScreen(
                title: title,
                playListId: playListId,
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
                Icons.arrow_forward_ios,
                color: Config.primaryColor,
                size: 18.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
