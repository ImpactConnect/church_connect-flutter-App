import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class DownloadService {
  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true; // iOS handles permissions differently
  }

  static Future<String?> downloadSermon(String url, String title) async {
    try {
      if (!await checkStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      // Get the downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final sermonDir = Directory('${directory.path}/sermons');
      if (!await sermonDir.exists()) {
        await sermonDir.create(recursive: true);
      }

      // Create a valid filename from the title
      final filename = '${title.replaceAll(RegExp(r'[^\w\s-]'), '')}.mp3';
      final filePath = path.join(sermonDir.path, filename);

      // Check if file already exists
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }

      // Download the file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to download sermon');
      }
    } catch (e) {
      print('Error downloading sermon: $e');
      return null;
    }
  }

  static Future<bool> isSermonDownloaded(String title) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filename = '${title.replaceAll(RegExp(r'[^\w\s-]'), '')}.mp3';
      final filePath = path.join(directory.path, 'sermons', filename);
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }
}
