import 'package:flutter/material.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:precious/utils/config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class GetInTouchScreen extends StatefulWidget {
  const GetInTouchScreen({super.key});

  @override
  State<GetInTouchScreen> createState() => _GetInTouchScreenState();
}

class _GetInTouchScreenState extends State<GetInTouchScreen> {
  @override
  void initState() {
    super.initState();
  }

  // Function to open a URL in the browser
  Future<void> openUrlInBrowser(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to make a phone call
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not call $phoneNumber';
    }
  }

  // Function to send an email
  Future<void> sendEmail(String emailAddress) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not email $emailAddress';
    }
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
          LocalizationService().translate('getInTouch'),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat-SemiBold',
            color: Config.darkColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: Config.screenWidth,
                child: Text(
                  LocalizationService().translate('supportTitle'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat-SemiBold',
                    color: Config.darkColor,
                  ),
                ),
              ),
              SizedBox(
                width: Config.screenWidth,
                child: Text(
                  LocalizationService().translate('supportText'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Montserrat-Regular',
                    color: Config.darkColor,
                  ),
                ),
              ),
              callUs(),
              emailUs(),
              ourWebsite(),
              tiktok(),
              facebook(),
              instagram()
            ],
          ),
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

  Widget callUs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          makePhoneCall('+250787011189');
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
                child: const Icon(Icons.call,
                    color: Config.primaryColor, size: 20.0),
              ),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService().translate('callUs'),
                    style: const TextStyle(
                      color: Config.darkColor,
                      fontFamily: 'Montserrat-SemiBold',
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    '+250787011189',
                    style: TextStyle(
                      color: Config.darkColor,
                      fontFamily: 'Montserrat-Regular',
                      fontSize: 12,
                    ),
                  )
                ],
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

  Widget emailUs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          sendEmail('info@preciouspresenttruth.org');
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
                child: const Icon(Icons.mail,
                    color: Config.primaryColor, size: 20.0),
              ),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150.0,
                    child: Text(
                      LocalizationService().translate('emailUs'),
                      style: const TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 150.0,
                    child: Text(
                      'info@preciouspresenttruth.org',
                      style: TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-Regular',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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

  Widget ourWebsite() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          openUrlInBrowser('https://preciouspresenttruth.org');
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
                child: const Icon(Icons.web,
                    color: Config.primaryColor, size: 20.0),
              ),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150.0,
                    child: Text(
                      LocalizationService().translate('ourWebsite'),
                      style: const TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 160.0,
                    child: Text(
                      'https://preciouspresenttruth.org',
                      style: TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-Regular',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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

  Widget tiktok() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          openUrlInBrowser('https://www.tiktok.com/@ppt.kinyarwanda');
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
                child: const Icon(Icons.tiktok,
                    color: Config.primaryColor, size: 20.0),
              ),
              const SizedBox(width: 15),
              const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150.0,
                    child: Text(
                      'Tiktok',
                      style: const TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 160.0,
                    child: Text(
                      '@ppt.kinyarwanda',
                      style: TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-Regular',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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

  Widget facebook() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          openUrlInBrowser(
              'https://www.facebook.com/profile.php?id=100088460659490');
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
                child: const Icon(Icons.facebook,
                    color: Config.primaryColor, size: 20.0),
              ),
              const SizedBox(width: 15),
              const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150.0,
                    child: Text(
                      'Facebook',
                      style: const TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 160.0,
                    child: Text(
                      '@preciouspresenttruth',
                      style: TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-Regular',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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

  Widget instagram() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          openUrlInBrowser(
              'https://www.instagram.com/preciouspresentfrancais/');
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
                child: const Icon(Icons.web,
                    color: Config.primaryColor, size: 20.0),
              ),
              const SizedBox(width: 15),
              const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150.0,
                    child: Text(
                      'Instagram',
                      style: const TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-SemiBold',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 160.0,
                    child: Text(
                      '@preciouspresent',
                      style: TextStyle(
                        color: Config.darkColor,
                        fontFamily: 'Montserrat-Regular',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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
