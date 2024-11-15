// lib/utils/file_utils.dart

import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileUtils {
  // Method to get the application documents directory
  static Future<String> getApplicationDocumentsDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Method to get the Hive box storage directory
  static Future<Directory> getHiveStorageDirectory() async {
    final path = await getApplicationDocumentsDirectoryPath();
    final hiveStoragePath = Directory('$path/hive');
    if (!await hiveStoragePath.exists()) {
      await hiveStoragePath.create(
          recursive: true); // Create directory if it doesn't exist
    }
    return hiveStoragePath;
  }
}
