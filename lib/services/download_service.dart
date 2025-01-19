import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class DownloadService {
  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      // Request both storage permissions for better compatibility
      final storage = await Permission.storage.status;
      final downloads = await Permission.manageExternalStorage.status;
      
      if (storage.isDenied || downloads.isDenied) {
        // Request both permissions
        final storageResult = await Permission.storage.request();
        final downloadsResult = await Permission.manageExternalStorage.request();
        return storageResult.isGranted || downloadsResult.isGranted;
      }
      return storage.isGranted || downloads.isGranted;
    }
    return true;
  }

  static Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Try to get the Downloads directory
        Directory? directory;
        
        // First try to get the Downloads directory
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          // Fallback to Music directory
          directory = Directory('/storage/emulated/0/Music');
        }
        
        // Create our app folder inside Downloads/Music
        final appDir = Directory('${directory.path}/ChurchConnect Sermons');
        if (!await appDir.exists()) {
          await appDir.create(recursive: true);
        }
        return appDir;
      } catch (e) {
        debugPrint('Error accessing download directory: $e');
        // Fallback to app's external directory if we can't access Downloads
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Could not access storage');
        }
        final appDir = Directory('${directory.path}/Sermons');
        if (!await appDir.exists()) {
          await appDir.create(recursive: true);
        }
        return appDir;
      }
    } else {
      // For iOS, use the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final appDir = Directory('${directory.path}/Sermons');
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      return appDir;
    }
  }

  static Future<String?> downloadSermon(String url, String title) async {
    try {
      if (!await checkStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      // Get the download directory
      final downloadDir = await getDownloadDirectory();
      
      // Create a valid filename from the title
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final filename = '$safeTitle.mp3';
      final filePath = path.join(downloadDir.path, filename);

      // Check if file already exists
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }

      // Download the file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('File saved to: $filePath');
        return filePath;
      } else {
        throw Exception('Failed to download sermon: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading sermon: $e');
      return null;
    }
  }

  static Future<bool> isSermonDownloaded(String title) async {
    try {
      final downloadDir = await getDownloadDirectory();
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final filename = '$safeTitle.mp3';
      final filePath = path.join(downloadDir.path, filename);
      return await File(filePath).exists();
    } catch (e) {
      debugPrint('Error checking sermon download status: $e');
      return false;
    }
  }

  static Future<String?> getSermonFilePath(String title) async {
    try {
      final downloadDir = await getDownloadDirectory();
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final filename = '$safeTitle.mp3';
      final filePath = path.join(downloadDir.path, filename);
      if (await File(filePath).exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting sermon file path: $e');
      return null;
    }
  }
}
