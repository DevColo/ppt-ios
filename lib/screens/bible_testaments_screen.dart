import 'package:flutter/material.dart';
import 'package:precious/providers/bible_provider.dart';
import 'package:precious/screens/bible_books_screen.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:precious/utils/config.dart';
import 'package:provider/provider.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final testaments = Provider.of<BibleProvider>(context).testaments;

    return Scaffold(
        backgroundColor: Config.greyColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationService().translate('bible'),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat-SemiBold',
                  color: Config.darkColor,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  openedBibleImg,
                  height: 180.0,
                ),
              ),
              isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Config.primaryColor))
                  : testaments.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: testaments.length,
                            itemBuilder: (context, index) {
                              final testament = testaments[index];
                              return testamentCard(
                                testament['id'],
                                testament['title'],
                                testament['pdf_link'],
                              );
                            },
                          ),
                        )
                      : const Center(child: Text('noData')),
            ],
          ),
        ));
  }

  Widget testamentCard(int id, String title, String pdfLink) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BibleBooksScreen(
                testament: id,
                title: title,
                pdfUrl: pdfLink,
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
                  color: Config.greyColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.book, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat-SemiBold',
                    color: Colors.black,
                  ),
                ),
              ),
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
