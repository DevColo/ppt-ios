import 'package:flutter/material.dart';

/* set constant config here */
class Config {
  static MediaQueryData? mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;

  //width and height initialization
  void init(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData!.size.width;
    screenHeight = mediaQueryData!.size.height;
  }

  static get widthSize {
    return screenWidth;
  }

  static get heightSize {
    return screenHeight;
  }

  //define spacing height
  static const spaceSmall = SizedBox(height: 15);
  static final spaceMedium = SizedBox(height: screenHeight! * 0.05);
  static final spaceBig = SizedBox(height: screenHeight! * 0.08);

  //textform field border
  static const outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: primaryColor,
      ));

  static const errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: Colors.red,
      ));

  // primary color
  //static const primaryColor = Color.fromARGB(255, 0, 91, 156);
  //static const primaryColor = Color.fromARGB(255, 0, 118, 164);
  static const primaryColor = Color.fromARGB(255, 0, 153, 254);
  static const primaryColorTransperant = Color.fromARGB(136, 0, 152, 254);

  // secondary color
  static const secondaryColor = Color.fromARGB(255, 103, 103, 103);
  static const secondaryColorTransperant = Color.fromARGB(119, 103, 103, 103);

  // white color
  static const whiteColor = Color.fromARGB(255, 255, 255, 255);
  static const whiteColorTransperant = Color.fromARGB(132, 255, 255, 255);

  // grey color
  static const greyColor = Color.fromARGB(255, 235, 235, 235);
  static const greyColorTransperant = Color.fromARGB(107, 235, 235, 235);

  // dark color
  static const darkColor = Color.fromARGB(255, 0, 0, 0);
  static const darkColorTransperant = Color.fromARGB(132, 0, 0, 0);

  // button width
  static get buttonNormalWidth {
    return btnNormalWidth;
  }

  static const btnNormalWidth = 280.0;

  // button height
  static get buttonNormalHeight {
    return btnNormalHeight;
  }

  static const btnNormalHeight = 45.0;
}
