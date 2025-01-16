import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  Future<void> showToast(String message) async {
    await Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Get external storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }

      // Get the external storage directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Could not access external storage');
      }

      // Create a specific directory for our app's sermons
      final sermonsDir = Directory('${directory.path}/ChurchConnect/Sermons');
      if (!await sermonsDir.exists()) {
        await sermonsDir.create(recursive: true);
      }

      return sermonsDir;
    } else {
      // For iOS, use the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final sermonsDir = Directory('${directory.path}/Sermons');
      if (!await sermonsDir.exists()) {
        await sermonsDir.create(recursive: true);
      }
      return sermonsDir;
    }
  }

  Future<List<FileSystemEntity>> getDownloadedSermons() async {
    try {
      final directory = await getDownloadDirectory();
      return directory.listSync();
    } catch (e) {
      print('Error getting downloaded sermons: $e');
      return [];
    }
  }

  Future<String?> downloadSermon({
    required String url,
    required String fileName,
    required String sermonId,
    required Function(double) onProgress,
  }) async {
    try {
      print('Starting sermon download...');
      print('URL: $url');
      print('File name: $fileName');

      await showToast('Starting download...');

      final sermonsDir = await getDownloadDirectory();
      print('Sermons directory: ${sermonsDir.path}');

      final localPath = '${sermonsDir.path}/$fileName';
      print('Local path: $localPath');
      final file = File(localPath);

      print('Initiating download...');
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      print('Response status code: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to download sermon audio: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      print('Content length: $contentLength bytes');
      int downloaded = 0;
      final List<int> bytes = [];

      print('Starting to read response stream...');
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        downloaded += chunk.length;
        if (contentLength > 0) {
          final progress = (downloaded / contentLength) * 100;
          print('Downloaded: $downloaded bytes ($progress%)');
          onProgress(progress);
          
          if (progress % 20 == 0) { // Show progress every 20%
            await showToast('Download progress: ${progress.toInt()}%');
          }
        }
      }

      print('Writing file to disk...');
      await file.writeAsBytes(bytes);
      print('File written successfully');

      await showToast('Download completed successfully!\nSaved to: ${sermonsDir.path}');
      return localPath;
    } catch (e, stackTrace) {
      print('Error downloading sermon: $e');
      print('Stack trace: $stackTrace');
      await showToast('Error downloading sermon: ${e.toString()}');
      return null;
    }
  }
}
