import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void showGlobalSnackBar(String text) {
  showSimpleNotification(
    Text(
      text,
      style: const TextStyle(
        color: Colors.black,
      ),
    ),
    background: const Color(0xFFDEE3EB),
    position: NotificationPosition.bottom,
    duration: const Duration(seconds: 4),
    trailing: Builder(builder: (context) {
      return TextButton(
        onPressed: () {
          OverlaySupportEntry.of(context)?.dismiss();
        },
        child: Text(
          'OK',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      );
    }),
    slideDismissDirection: DismissDirection.horizontal,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
  );
}