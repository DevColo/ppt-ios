import 'package:flutter/material.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/screens/audio_screen.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:precious/utils/config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AudioBooksScreen extends StatefulWidget {
  const AudioBooksScreen({super.key});

  @override
  State<AudioBooksScreen> createState() => _AudioBooksScreenState();
}

class _AudioBooksScreenState extends State<AudioBooksScreen> {
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

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Column(
          children: [
            const SizedBox(height: 5.0),
            if (selectedLanguage == 'English')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
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
            const SizedBox(height: 5.0),
            if (selectedLanguage != 'English')
              Expanded(
                child: isLoading
                    ? GridView.builder(
                        itemCount: 9,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 0.65,
                        ),
                        itemBuilder: (context, index) => shimmerAudioBook(),
                      )
                    : audioBooks.isNotEmpty
                        ? GridView.builder(
                            itemCount: audioBooks.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 0.65,
                            ),
                            itemBuilder: (context, index) {
                              final book = audioBooks[index];
                              return audioBookCard(
                                book['id'],
                                book['title'],
                                book['author'],
                                book['image_link'],
                                book['pdf_link'],
                                book['description'],
                              );
                            },
                          )
                        : Center(
                            child:
                                Text(LocalizationService().translate('noData')),
                          ),
              ),
          ],
        ),
      ),
    );
  }

  Widget shimmerAudioBook() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget audioBookCard(
    int id,
    String title,
    String author,
    String imageUrl,
    String pdfLink,
    String description,
  ) {
    return GestureDetector(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, color: Colors.red),
        ),
      ),
    );
  }
}
