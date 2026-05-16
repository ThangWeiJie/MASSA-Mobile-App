import 'dart:typed_data';

class EventImageUpload {
  final String fileName;
  final Uint8List bytes;
  final String? contentType;

  const EventImageUpload({
    required this.fileName,
    required this.bytes,
    this.contentType,
  });
}
