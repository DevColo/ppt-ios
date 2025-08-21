import 'package:flutter/material.dart';
import 'package:precious/components/floating_audio_player.dart';
import 'package:precious/screens/audio_screen.dart';
import 'package:precious/screens/video_collection_screen.dart';
import 'package:precious/utils/config.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> booksResults = [];
  List<dynamic> pastorsResults = [];
  List<dynamic> videosResults = [];
  bool isLoading = false;
  bool resultsLoaded = false;

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        booksResults = [];
        pastorsResults = [];
        videosResults = [];
        resultsLoaded = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';
      final response = await http.get(
        Uri.parse(
            'https://ppt-app.net/api/$selectedLanguage/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          booksResults = data['results']['books'];
          pastorsResults = data['results']['pastors'];
          videosResults = data['results']['videos'];
          isLoading = false;
          resultsLoaded = true;
        });
      } else {
        setState(() {
          booksResults = [];
          pastorsResults = [];
          videosResults = [];
          isLoading = false;
          resultsLoaded = false;
        });
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(LocalizationService().translate('searchError'))),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocalizationService().translate('networkError'))),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          LocalizationService().translate('search'),
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat-SemiBold',
            color: Config.darkColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: LocalizationService().translate('searchPlaceholder'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 20.0,
                ),
              ),
              onChanged: (value) {
                // Debounce the search to avoid too many requests
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (value == _searchController.text) {
                    performSearch(value);
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (!resultsLoaded &&
                booksResults.isEmpty &&
                pastorsResults.isEmpty &&
                videosResults.isEmpty)
              Text(
                LocalizationService().translate('searchResultText'),
                style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              )
            else if (resultsLoaded &&
                booksResults.isEmpty &&
                pastorsResults.isEmpty &&
                videosResults.isEmpty)
              Text(
                LocalizationService().translate('noData'),
                style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              )
            else
              Expanded(
                child: ListView(
                  children: [
                    if (booksResults.isNotEmpty)
                      ...booksResults.map((book) {
                        return audioBookCard(
                          book['id'],
                          book['title'],
                          book['author'],
                          book['image_link'],
                          book['pdf_link'],
                          book['description'],
                        );
                      }).toList(),
                    if (pastorsResults.isNotEmpty)
                      ...pastorsResults.map((pastor) {
                        return pastorCard(
                          pastor['id'],
                          pastor['fullname'],
                          pastor['bio'] ?? '',
                          pastor['image_link'],
                        );
                      }).toList(),
                    // if (videosResults.isNotEmpty)
                    //   ...videosResults.map((video) {
                    //     return videoCard(
                    //       video['title'],
                    //       video['video_link'],
                    //     );
                    //   }).toList(),
                  ],
                ),
              ),
            FloatingAudioControl(),
          ],
        ),
      ),
    );
  }

  Widget audioBookCard(int id, String title, String author, String imageUrl,
      String pdfLink, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to the AudioScreen when tapped
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
                      if (loadingProgress == null) {
                        return child;
                      }
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
                        fontSize: 11),
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

  Widget pastorCard(int id, String fullname, String bio, String imageURL) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to the AudioScreen when tapped
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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageURL,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
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
              const SizedBox(width: 15),
              Text(
                _trimFullname(fullname),
                style: const TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Config.primaryColor, size: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  // Widget videoCard(String title, String videoLink) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 5.0),
  //     child: GestureDetector(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => VideoScreen(
  //               title: title,
  //               videoLink: videoLink,
  //             ),
  //           ),
  //         );
  //       },
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         padding:
  //             const EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 8.0),
  //         child: Row(
  //           children: [
  //             Container(
  //               height: 50,
  //             ),
  //             const SizedBox(width: 20.0),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 SizedBox(
  //                   width: 230,
  //                   //height: 40.0,
  //                   child: Text(
  //                     title,
  //                     style: const TextStyle(
  //                       color: Color.fromARGB(255, 0, 0, 0),
  //                       fontFamily: 'Montserrat-SemiBold',
  //                       fontSize: 13,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const Spacer(),
  //             const Icon(
  //               Icons.play_circle_fill,
  //               color: Config.primaryColor,
  //               size: 25.0,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

String _trimFullname(String fullname) {
  // Split the fullname into words
  final words = fullname.split(' ');

  // If more than two words, keep only the first two
  if (words.length > 2) {
    return '${words[0]} ${words[1]}';
  }

  // Otherwise, return the fullname as is
  return fullname;
}
