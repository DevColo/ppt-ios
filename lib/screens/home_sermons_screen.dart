import 'package:flutter/material.dart';
import 'package:precious/providers/sermons_provider.dart';
import 'package:precious/screens/video_collection_screen.dart';
import 'package:precious/screens/video_screen.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:precious/utils/config.dart';
import 'package:shimmer/shimmer.dart';

class HomeSermonsScreen extends StatefulWidget {
  const HomeSermonsScreen({super.key});

  @override
  State<HomeSermonsScreen> createState() => _HomeSermonsScreenState();
}

class _HomeSermonsScreenState extends State<HomeSermonsScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final pastors = Provider.of<SermonsProvider>(context).pastors;
    final videos = Provider.of<SermonsProvider>(context).youtube;

    return Scaffold(
      backgroundColor: Config.greyColor,
      appBar: AppBar(
        title: Text(
          LocalizationService().translate('sermons'),
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat-SemiBold',
            color: Config.darkColor,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Config.darkColor,
          ),
          onPressed: () => Navigator.pushNamed(context, 'main'),
        ),
      ),
      body: isLoading
          ? buildSkeletonScreen()
          : pastors.isNotEmpty
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5.0),
                        // Wrap GridView in a SizedBox to give it a fixed height
                        SizedBox(
                          // Adjust height as needed
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: pastors.length,
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(), // Prevent inner scroll
                            itemBuilder: (context, index) {
                              final pastor = pastors[index];
                              return pastorGridItem(
                                pastor['id'],
                                _trimFullname(pastor['fullname']),
                                pastor['fullname'],
                                pastor['bio'] ?? '',
                                pastor['image_link'],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        videos.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: videos.length,
                                itemBuilder: (context, index) {
                                  final book = videos[index];
                                  return youtubeVideo(
                                    book['id'],
                                    book['title'],
                                    book['video_link'],
                                  );
                                },
                              )
                            : const Center(child: Text('')),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Text(LocalizationService().translate('noData')),
                ),
    );
  }

  // Bible Verses
  Widget youtubeVideo(int playListID, String title, String videoLink) {
    String videoId = getYoutubeVideoId(videoLink);
    String thumbnailUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 0.0,
      ),
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
            color: Config.whiteColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnailUrl,
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontFamily: 'Montserrat-SemiBold',
                    fontSize: 11,
                  ),
                ),
              ),
              const Icon(
                Icons.play_circle_rounded,
                color: Config.primaryColor,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getYoutubeVideoId(String url) {
    final Uri uri = Uri.parse(url);
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    } else if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }
    return '';
  }

  Widget buildSkeletonScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 60,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget pastorGridItem(int id, String trimmedFullName, String fullname,
      String bio, String imageURL) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCollectionScreen(
              pastorId: id,
              pastorName: fullname,
              pastorBio: bio,
              imageUrl: imageURL,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageURL,
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            trimmedFullName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Config.darkColor,
              fontSize: 11,
              fontFamily: 'Montserrat-SemiBold',
            ),
          ),
        ],
      ),
    );
  }

  String _trimFullname(String fullname) {
    final words = fullname.split(' ');
    return words.length > 2 ? '${words[0]} ${words[1]}' : fullname;
  }
}
