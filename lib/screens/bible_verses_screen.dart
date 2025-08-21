import 'package:flutter/material.dart';
import 'package:precious/components/floating_audio_player.dart';
import 'package:precious/providers/bible_verses_provider.dart';
import 'package:precious/screens/bible_verse_screen.dart';
import 'package:precious/utils/config.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class BibleVersesScreen extends StatefulWidget {
  const BibleVersesScreen({super.key});

  @override
  State<BibleVersesScreen> createState() => _BibleVersesScreenState();
}

class _BibleVersesScreenState extends State<BibleVersesScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Simulate data fetching and update the loading state
  Future<void> _loadData() async {
    // isLoading = true;
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final verses = Provider.of<BibleVersesProvider>(context).verses;

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
          onPressed: () => Navigator.pushNamed(context, 'main'),
        ),
        title: Text(
          LocalizationService().translate('bibleVerses'),
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
                    itemCount: 5,
                    itemBuilder: (context, index) => shimmerBibleVerses(),
                  )
                : verses.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: verses.length,
                        itemBuilder: (context, index) {
                          final book = verses[index];
                          return bibleVerse(
                            book['id'],
                            book['title'],
                            book['video_link'],
                          );
                        },
                      )
                    : Center(
                        child: Text(LocalizationService().translate('noData')),
                      ),
            FloatingAudioControl(),
          ],
        ),
      ),
    );
  }

  // shimmer Bible Verses
  Widget shimmerBibleVerses() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
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
    );
  }

  Widget bibleVerse(int id, String title, String videoLink) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: () {
          //Navigate to the BibleVerseScreen when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BibleVerseScreen(
                title: title,
                videoLink: videoLink,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Config.whiteColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.only(
              left: 10.0, top: 10.0, bottom: 10.0, right: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 20.0),
                  SizedBox(
                    width: 170.0,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Config.primaryColor,
                size: 16.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
