import 'package:flutter/material.dart';
import 'package:precious/src/static_images.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:precious/utils/config.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

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
          LocalizationService().translate('aboutUs'),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat-SemiBold',
            color: Config.darkColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 20.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Config.greyColor,
                ),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      preciousLogo,
                      width: 150.0,
                    ),
                  ],
                ),
              ),
              Text(
                LocalizationService().translate('about'),
                style: const TextStyle(
                  fontSize: 16,
                  //fontFamily: 'Montserrat-SemiBold',
                  color: Config.darkColor,
                  height: 2.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
