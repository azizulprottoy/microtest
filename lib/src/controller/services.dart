import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PickedFileResult {
  final String path;
  final int size;
  final String? mimeType;

  PickedFileResult({
    required this.path,
    required this.size,
    this.mimeType,
  });
}

class FileService {
  static Future<PickedFileResult?> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;

      return PickedFileResult(
        path: file.path!,
        size: file.size,
        mimeType:  _MimeType(file.name),
      );
    }

    return null;
  }

  static String? _MimeType(String filename) {
    if (filename.endsWith('.pdf')) return 'application/pdf';
    if (filename.endsWith('.png')) return 'image/png';
    if (filename.endsWith('.jpg') || filename.endsWith('.jpeg')) return 'image/jpeg';
    if (filename.endsWith('.mp4')) return 'video/mp4';
    return null;
  }

  static Future<PickedFileResult?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 70);
    if (image == null) return null;

    final bytes = await image.readAsBytes();
    return PickedFileResult(
      path: image.path,
      size: bytes.length,
      mimeType: 'image/${image.path.split('.').last}',
    );
  }
  static download(String uri, String name) async {
    final client = http.Client();
    final request = await client.get(Uri.parse(uri));
    final bytes = request.bodyBytes;
    final documentsDir = (await getApplicationDocumentsDirectory()).path;
    final localPath = '$documentsDir/$name';

    if (File(localPath).existsSync()) return;

    final file = File(localPath);
    await file.writeAsBytes(bytes);
  }
}
