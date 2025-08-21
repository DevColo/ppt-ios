import 'package:flutter/material.dart';
import 'package:precious/utils/localization_service.dart';
import 'package:precious/utils/config.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({Key? key}) : super(key: key);

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
          LocalizationService().translate('donations'),
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
          horizontal: 10.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bank Account Details Section
              Text(
                LocalizationService().translate('bankAccountDetails'),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat-SemiBold',
                  color: Config.darkColor,
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Config.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService().translate('bankName') +
                          ': XYZ Bank',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat-SemiBold',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      LocalizationService().translate('accountNumber') +
                          ': 123456789',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat-SemiBold',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Mobile Money Details Section
              Text(
                LocalizationService().translate('mobileMoneyDetails'),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat-SemiBold',
                  color: Config.darkColor,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Config.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService().translate('mtnMobileMoney') +
                          ': 0771234567',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat-SemiBold',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      LocalizationService().translate('airtelTigoMoney') +
                          ': 0777654321',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat-SemiBold',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      LocalizationService().translate('vodafoneCash') +
                          ': 0771122334',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Montserrat-SemiBold',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
