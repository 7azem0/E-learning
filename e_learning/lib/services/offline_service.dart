import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final Dio _dio = Dio();
  static const String _downloadedKey = 'downloaded_lessons';

  Future<String?> getLocalPath(String courseId, String lessonId, String type) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${courseId}_${lessonId}_$type.${type == 'pdf' ? 'pdf' : 'mp4'}';
    final file = File('${dir.path}/$fileName');
    
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<void> downloadLesson({
    required String courseId,
    required String lessonId,
    required String url,
    required String type,
    required Function(double) onProgress,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${courseId}_${lessonId}_$type.${type == 'pdf' ? 'pdf' : 'mp4'}';
      final filePath = '${dir.path}/$fileName';

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      final prefs = await SharedPreferences.getInstance();
      final downloaded = prefs.getStringList(_downloadedKey) ?? [];
      final key = '${courseId}_${lessonId}_$type';
      if (!downloaded.contains(key)) {
        downloaded.add(key);
        await prefs.setStringList(_downloadedKey, downloaded);
      }
    } catch (e) {
      debugPrint('Download error: $e');
      rethrow;
    }
  }

  Future<bool> isDownloaded(String courseId, String lessonId, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList(_downloadedKey) ?? [];
    final key = '${courseId}_${lessonId}_$type';
    if (!downloaded.contains(key)) return false;

    final path = await getLocalPath(courseId, lessonId, type);
    return path != null;
  }

  Future<void> removeDownload(String courseId, String lessonId, String type) async {
    final path = await getLocalPath(courseId, lessonId, type);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList(_downloadedKey) ?? [];
    final key = '${courseId}_${lessonId}_$type';
    downloaded.remove(key);
    await prefs.setStringList(_downloadedKey, downloaded);
  }
}
