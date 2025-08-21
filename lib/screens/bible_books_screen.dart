import 'package:flutter/material.dart';
import 'package:precious/components/floating_audio_player.dart';
import 'package:precious/providers/bible_provider.dart';
import 'package:precious/screens/bible_book_audio_screen.dart';
import 'package:precious/screens/pdf_book_view.dart';
import 'package:precious/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class BibleBooksScreen extends StatefulWidget {
  final int testament;
  final String title;
  final String pdfUrl;

  const BibleBooksScreen({
    super.key,
    required this.testament,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<BibleBooksScreen> createState() => _BibleBooksScreenState();
}

class _BibleBooksScreenState extends State<BibleBooksScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBibleBooks();
    _loadData();
  }

  Future<void> fetchBibleBooks() async {
    await Provider.of<BibleProvider>(context, listen: false)
        .getBibleBooks(context, widget.testament);
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
    final bibleBooks = Provider.of<BibleProvider>(context).books;

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
            fontSize: 14,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.book, color: Config.primaryColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PDFBookView(title: widget.title, pdfUrl: widget.pdfUrl),
              ),
            ),
          ),
        ],
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
                    itemBuilder: (context, index) => shimmerBibleBooks(),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bibleBooks.length,
                    itemBuilder: (context, index) {
                      final video = bibleBooks[index];
                      return bibleBookCard(
                        video['id'],
                        video['title'],
                      );
                    },
                  ),
            const Center(child: FloatingAudioControl()),
          ],
        ),
      ),
    );
  }

  Widget shimmerBibleBooks() {
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
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

  Widget bibleBookCard(int id, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BibleBookAudioScreen(
                bookID: id,
                title: title,
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
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
