import 'package:flutter/material.dart';

void showLoadingDialog(String text, BuildContext context) => showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(text, textAlign: TextAlign.center),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
