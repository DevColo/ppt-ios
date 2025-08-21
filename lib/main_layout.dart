// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/providers/collections_provider.dart';
import 'package:precious/providers/sermons_provider.dart';
import 'package:precious/screens/about_screen.dart';
import 'package:precious/screens/audio_books_screen.dart';
import 'package:precious/screens/bible_testaments_screen.dart';
import 'package:precious/screens/downloaded_audios_screen.dart';
import 'package:precious/screens/get_in_touch_screen.dart';
import 'package:precious/screens/home_downloaded_audios_screen.dart';
import 'package:precious/screens/home_screen.dart';
import 'package:precious/screens/search_screen.dart';
import 'package:precious/screens/sermons_screen.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:precious/components/floating_audio_player.dart';
import 'package:url_launcher/url_launcher.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentPage = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedLanguage = 'Kinyarwanda';

  // Supported languages with display names, flags, and codes.
  final List<Map<String, String>> languages = [
    {'language': 'English', 'flag': 'assets/images/english.png', 'code': 'en'},
    {'language': 'French', 'flag': 'assets/images/french.png', 'code': 'fr'},
    {
      'language': 'Kinyarwanda',
      'flag': 'assets/images/kinyarwanda.png',
      'code': 'rw'
    },
    {
      'language': 'Swahili',
      'flag': 'assets/images/kiswahili.png',
      'code': 'sw'
    },
    {'language': 'Lingala', 'flag': 'assets/images/lingala.png', 'code': 'lg'},
    {'language': 'Tshiluba', 'flag': 'assets/images/default.png', 'code': 'ts'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentPage = prefs.getInt('currentPage') ?? 0;
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'Kinyarwanda';
    });
    _pageController.jumpToPage(currentPage);
    await _applyLanguage(selectedLanguage);
  }

  Future<void> _savePage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPage', page);
  }

  Future<void> _applyLanguage(String language) async {
    // Find the language code based on the display name.
    final languageCode =
        languages.firstWhere((lang) => lang['language'] == language)['code']!;
    await LocalizationService().loadLanguage(languageCode);
    // Trigger rebuild after loading the language.
    setState(() {});
  }

  Future<void> _fetchDataBasedOnLanguage() async {
    await Provider.of<CollectionsProvider>(context, listen: false)
        .getAllCollections();

    final sermonsProvider =
        Provider.of<SermonsProvider>(context, listen: false);
    await sermonsProvider.getPastors();
    await sermonsProvider.getYoutube();

    final audioProvider =
        Provider.of<AudioBooksProvider>(context, listen: false);
    await audioProvider.getAudioBooks();

    //final appProvider = Provider.of<AppProvider>(context, listen: false);
    // await appProvider.getPreachers();
    //await appProvider.getMostReadBooks();

    //final bibleProvider = Provider.of<BibleProvider>(context, listen: false);
    //await bibleProvider.getTestaments();

    //final bibleVersesProvider = Provider.of<BibleVersesProvider>(context, listen: false);
    //await bibleVersesProvider.getVerses();
  }

  void _changeLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          LocalizationService().translate('selectLanguage'),
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Montserrat-SemiBold',
            color: Config.darkColor,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: languages.map((language) {
              return ListTile(
                leading: Image.asset(language['flag']!, width: 30, height: 30),
                title: Text(language['language']!),
                onTap: () async {
                  Navigator.of(context)
                      .pop(); // Close language selection dialog
                  _showLoadingDialog(context);

                  try {
                    setState(() {
                      selectedLanguage = language['language']!;
                    });

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('selectedLanguage', selectedLanguage);

                    await _applyLanguage(selectedLanguage);

                    // Refetch all necessary data
                    await _fetchDataBasedOnLanguage();

                    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                  } catch (error) {
                    // Optional: Show an error message
                    print('Error fetching data: $error');
                  } finally {
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          color: Config.primaryColor,
        ),
      ),
    );
  }

  ListTile _drawerItem(
      IconData icon, String translationKey, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(LocalizationService().translate(translationKey)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 24.0),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
        backgroundColor: Config.whiteColor,
        surfaceTintColor: Config.whiteColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Config.primaryColor),
              child: Image(
                image: AssetImage(preciousLogo),
                fit: BoxFit.contain,
              ),
            ),
            _drawerItem(Icons.home, 'home', () {
              _pageController.jumpToPage(0);
              Navigator.pop(context);
            }),
            _drawerItem(Icons.church_rounded, 'aboutUs', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutScreen()),
              );
            }),
            _drawerItem(Icons.support, 'donations', () {
              onTap:
              () async {
                final Uri url =
                    Uri.parse("https://preciouspresenttruth.org/donate");
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  throw 'Could not launch $url';
                }
              };
            }),
            _drawerItem(Icons.help_center, 'charity', () {
              onTap:
              () async {
                final Uri url = Uri.parse("https://preciouspresenttruth.org/");
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  throw 'Could not launch $url';
                }
              };
            }),
            _drawerItem(Icons.contact_page, 'getInTouch', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GetInTouchScreen(),
                ),
              );
            }),
            _drawerItem(Icons.download, 'downloads', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DownloadedAudiosScreen()),
              );
            }),
            _drawerItem(Icons.search, 'search', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            }),
            const Divider(),
            _drawerItem(Icons.language, 'changeLanguage',
                () => _changeLanguage(context)),
            // _drawerItem(Icons.refresh, 'refresh',
            //     () async => await _fetchDataBasedOnLanguage()),
            _drawerItem(Icons.logout, 'exit', () => exit(0)),
          ],
        ),
      ),
      // ignore: prefer_const_constructors
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                currentPage = value;
                _savePage(currentPage);
              });
            },
            children: <Widget>[
              HomeScreen(selectedLanguage: selectedLanguage),
              SermonsScreen(),
              AudioBooksScreen(),
              selectedLanguage == 'Kinyarwanda'
                  ? BibleScreen()
                  : HomeDownloadedAudiosScreen(),
            ],
          ),
          FloatingAudioControl(),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Config.greyColor,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: BottomNavigationBar(
            currentIndex: currentPage,
            onTap: (page) {
              setState(() {
                currentPage = page;
                _pageController.animateToPage(
                  page,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
                _savePage(currentPage);
              });
            },
            selectedItemColor: Config.primaryColor,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(color: Config.primaryColor),
            unselectedLabelStyle: const TextStyle(color: Colors.grey),
            backgroundColor: Config.whiteColor,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 5.0,
            selectedFontSize: 7.5,
            unselectedFontSize: 7.5,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_filled),
                label: LocalizationService().translate('home'),
                backgroundColor: Config.whiteColor,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people),
                label: LocalizationService().translate('pastors'),
                backgroundColor: Config.whiteColor,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.headphones),
                label: LocalizationService().translate('audioBooks'),
                backgroundColor: Config.whiteColor,
              ),
              selectedLanguage == 'Kinyarwanda'
                  ? BottomNavigationBarItem(
                      icon: const Icon(Icons.book),
                      label: LocalizationService().translate('bible'),
                      backgroundColor: Config.whiteColor,
                    )
                  : BottomNavigationBarItem(
                      icon: const Icon(Icons.download),
                      label: LocalizationService().translate('downloads'),
                      backgroundColor: Config.whiteColor,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
