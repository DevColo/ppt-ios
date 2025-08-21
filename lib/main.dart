import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:precious/components/audio_player_handler.dart';
import 'package:precious/providers/audio_player_provider.dart';
import 'package:precious/providers/bible_provider.dart';
import 'package:precious/providers/bible_verses_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:precious/providers/audio_books_provider.dart';
import 'package:precious/providers/categories_provider.dart';
import 'package:precious/providers/sermons_provider.dart';
import 'package:precious/screens/get_in_touch_screen.dart';
import 'package:precious/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:precious/main_layout.dart';
import 'package:precious/screens/welcome_screen.dart';
import 'package:precious/providers/app_provider.dart';
import 'package:precious/providers/collections_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CollectionsProvider()),
        ChangeNotifierProvider(create: (_) => SermonsProvider()),
        ChangeNotifierProvider(create: (_) => AudioBooksProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => BibleVersesProvider()),
        ChangeNotifierProvider(create: (_) => BibleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Navigator key for push navigation
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _scheduleNotification();
  }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Schedule a notification after 2 minutes
  Future<void> _scheduleNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Unique channel ID
      'Scheduled Notifications',
      channelDescription: 'Channel for scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Reminder',
      'Check out a new released audio book!',
      tz.TZDateTime.now(tz.local)
          .add(const Duration(minutes: 2)), // Fire after 2 minutes
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        'main': (context) => const MainLayout(),
        'settings': (context) => const SettingsScreen(),
        'get_in_touch': (context) => const GetInTouchScreen(),
      },
    );
  }
}
