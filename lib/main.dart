import 'package:flutter/material.dart';
import 'package:green_table/pages/login_page.dart';
import 'package:green_table/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() async {
  // Ensure that Hive is initialized before the app starts
  WidgetsFlutterBinding.ensureInitialized();

  // Get the application document directory to store Hive data
  final appDocumentDir = await getApplicationDocumentsDirectory();

  // Create a custom directory inside the documents folder for Hive data
  final hiveDirectory = Directory('${appDocumentDir.path}/hive');

  // Check if the directory exists, if not, create it
  if (!await hiveDirectory.exists()) {
    await hiveDirectory.create(recursive: true);
  }

  // Initialize Hive with the custom directory path
  await Hive.initFlutter(hiveDirectory.path);

  // Open a box to store theme data or other app-specific data
  await Hive.openBox('appSettings');

  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
