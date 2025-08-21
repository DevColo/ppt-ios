import 'package:flutter/material.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:precious/utils/config.dart';
import 'package:shimmer/shimmer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
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
          LocalizationService().translate('settings'),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat-SemiBold',
            color: Config.darkColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService().translate('support'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat-SemiBold',
                      color: Config.darkColor,
                    ),
                  ),
                ],
              ),
            ),
            getInTouch(),
          ],
        ),
      ),
    );
  }

  Widget buildSkeletonScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // Make the content scrollable
        child: Column(
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget getInTouch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, 'get_in_touch');
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Config.greyColorTransperant,
                ),
                child: const Icon(Icons.message_outlined,
                    color: Config.primaryColor, size: 20.0),
              ),
              const SizedBox(width: 15),
              Text(
                LocalizationService().translate('getInTouch'),
                style: const TextStyle(
                  color: Config.darkColor,
                  fontFamily: 'Montserrat-SemiBold',
                  fontSize: 16,
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
}
