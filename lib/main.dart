import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pos_app/screens/login_screen.dart';
import 'package:pos_app/services/sqlite_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await Hive.initFlutter();
  await Hive.openBox('mysql_config');
  await Hive.openBox('userInfo');

  // SQFLite
  await SqliteService.initializeDB();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A71DB)),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}