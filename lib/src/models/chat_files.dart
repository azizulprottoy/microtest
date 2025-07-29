
import 'dart:io';

class FileUploaded {
  final String name;
  final String mimeType;
  final String url;
  final String? path;
  final num size;

  FileUploaded({
    required this.name,
    required this.mimeType,
    required this.url,
    this.path,
    required this.size,


  });

  factory FileUploaded.fromJson(Map<String, dynamic> map) {
    return FileUploaded(
      name: map['fileName'] as String,
      mimeType: map['mimeType'] as String,
      url: map['url'] ?? map['uri'] as String,
      path: map['path'] as String?,
      size: map['size'] as num,

    );
  }

  Map<String, dynamic> get toJson => {
    'fileName': name,
    'mimeType': mimeType,
    'url': url,
    'path': path,
    'size': size,

  };
}

class FileUploadDto {
  final File file;
  final String type;
  final String? mimeType;
  final num size;

  FileUploadDto({
    required this.file,
    required this.type,
    required this.mimeType,
    required this.size,
  });
}


