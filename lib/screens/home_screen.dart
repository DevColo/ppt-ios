import 'package:flutter/material.dart';
import 'package:precious/screens/home_sermons_screen.dart';
import 'package:precious/screens/egw_audio_books_screen.dart';
import 'package:precious/screens/home_bible_testaments_screen.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:precious/utils/config.dart';

class HomeScreen extends StatefulWidget {
  final String selectedLanguage;

  const HomeScreen({Key? key, required this.selectedLanguage})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Simulate data fetching and update the loading state
  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(
        backgroundColor: Config.greyColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              //vertical: 10.0,
              horizontal: 10.0,
            ),
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.selectedLanguage == 'Kinyarwanda')
                      bibleTestaments(),
                    egwBooks(),
                    sermons(),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget bibleTestaments() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeBibleScreen(),
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
                width: 90,
                height: 100,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(bibleImg),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Config.whiteColor,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  LocalizationService().translate('bible'),
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

  Widget egwBooks() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EGWAudioBooksScreen(),
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
                width: 90,
                height: 100,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(egw),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Config.whiteColor,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  LocalizationService().translate('egwBooks'),
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

  Widget sermons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeSermonsScreen(),
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
                width: 90,
                height: 100,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(preciousLogo),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Config.whiteColor,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  LocalizationService().translate('sermons'),
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
