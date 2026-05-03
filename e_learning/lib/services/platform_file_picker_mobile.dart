import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> pickFile(String accept) async {
  final isPdf = accept.contains('pdf');
  final result = await FilePicker.platform.pickFiles(
    type: isPdf ? FileType.custom : FileType.video,
    allowedExtensions: isPdf ? ['pdf'] : null,
    withData: true,
  );
  if (result == null || result.files.single.bytes == null) return null;
  return {
    'bytes': result.files.single.bytes!,
    'name': result.files.single.name,
  };
}

Future<Uint8List?> fetchFileBytes(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return response.bodyBytes;
    return null;
  } catch (e) {
    return null;
  }
}