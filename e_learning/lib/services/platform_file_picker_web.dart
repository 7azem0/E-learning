import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

Future<Map<String, dynamic>?> pickFile(String accept) async {
  final completer = Completer<html.File?>();
  final input = html.FileUploadInputElement();
  input.accept = accept;
  input.click();
  input.onChange.listen((e) {
    if (input.files!.isEmpty) {
      completer.complete(null);
    } else {
      completer.complete(input.files!.first);
    }
  });
  final htmlFile = await completer.future;
  if (htmlFile == null) return null;

  final reader = html.FileReader();
  reader.readAsArrayBuffer(htmlFile);
  await reader.onLoad.first;
  final bytes = Uint8List.fromList(reader.result as List<int>);
  return {'bytes': bytes, 'name': htmlFile.name};
}

Future<Uint8List?> fetchFileBytes(String url) async {
  final completer = Completer<Uint8List?>();
  final request = html.HttpRequest();
  request.open('GET', url);
  request.responseType = 'arraybuffer';
  request.onLoad.listen((_) {
    final bytes = Uint8List.view(request.response as dynamic);
    completer.complete(bytes);
  });
  request.onError.listen((_) => completer.complete(null));
  request.send();
  return completer.future;
}