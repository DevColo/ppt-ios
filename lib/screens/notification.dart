import 'dart:async';
import 'package:flutter/material.dart';

class PopupNotificationAfterTwoMinutes extends StatefulWidget {
  final Widget child;
  const PopupNotificationAfterTwoMinutes({Key? key, required this.child})
      : super(key: key);

  @override
  _PopupNotificationAfterTwoMinutesState createState() =>
      _PopupNotificationAfterTwoMinutesState();
}

class _PopupNotificationAfterTwoMinutesState
    extends State<PopupNotificationAfterTwoMinutes> {
  @override
  void initState() {
    super.initState();
    // Wait for 2 minutes before showing the popup.
    Future.delayed(const Duration(minutes: 2), () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Notification"),
              content: const Text(
                  "This is a custom popup notification displayed after 2 minutes."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Dismiss"),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
