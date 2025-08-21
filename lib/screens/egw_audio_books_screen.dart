import 'package:flutter/material.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/screens/audio_screen.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:precious/utils/config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EGWAudioBooksScreen extends StatefulWidget {
  const EGWAudioBooksScreen({super.key});

  @override
  State<EGWAudioBooksScreen> createState() => _EGWAudioBooksScreenState();
}

class _EGWAudioBooksScreenState extends State<EGWAudioBooksScreen> {
  bool isLoading = true;
  String selectedLanguage = 'Kinyarwanda';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadLanguage();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  // Loads the saved language from SharedPreferences
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

  // Opens an external URL using url_launcher
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    final audioBooks = Provider.of<AudioBooksProvider>(context).audioBooks;

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
          LocalizationService().translate('egwBooks'),
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat-SemiBold',
            color: Config.darkColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 10.0),
        child: Column(
          children: [
            const SizedBox(height: 5.0),
            // Display external link if selected language is English
            if (selectedLanguage == 'English')
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                child: GestureDetector(
                  onTap: () {
                    const url = 'https://egwwritings.org/allCollection/en/4';
                    _launchURL(url);
                  },
                  child: const Text(
                    'Visit EGWWritings website',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontFamily: 'Montserrat-Regular',
                    ),
                  ),
                ),
              ),

            // Audio Books list or shimmer effect
            Expanded(
                child: isLoading
                    ? selectedLanguage == 'English'
                        ? const SizedBox()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 6,
                            itemBuilder: (context, index) => shimmerAudioBook(),
                          )
                    : audioBooks.isNotEmpty
                        ? ListView.builder(
                            itemCount: audioBooks.length,
                            itemBuilder: (context, index) {
                              final audioBook = audioBooks[index];
                              return audioBookCard(
                                audioBook['id'],
                                audioBook['title'],
                                audioBook['author'],
                                audioBook['image_link'],
                                audioBook['pdf_link'],
                                audioBook['description'],
                              );
                            },
                          )
                        : selectedLanguage == 'English'
                            ? const SizedBox()
                            : Center(
                                child: Text(
                                    LocalizationService().translate('noData')),
                              )),
          ],
        ),
      ),
    );
  }

  // Shimmer placeholder widget while loading
  Widget shimmerAudioBook() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
              ),
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
              color: Colors.grey,
              size: 25.0,
            ),
          ],
        ),
      ),
    );
  }

  // Audio Book Card Widget
  Widget audioBookCard(
    int id,
    String title,
    String author,
    String imageUrl,
    String pdfLink,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioScreen(
                bookID: id,
                pdfUrl: pdfLink,
                author: author,
                title: title,
                imageUrl: imageUrl,
                description: description,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    author,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 99, 99, 99),
                      fontFamily: 'Montserrat-SemiBold',
                      fontSize: 11,
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
