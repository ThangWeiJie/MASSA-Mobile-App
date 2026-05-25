import 'package:cloud_firestore/cloud_firestore.dart';

class EventDocumentModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final String fileExtension;
  final String storagePath;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? parentFolderId;
  final bool isFolder;
  final String fileType;

  EventDocumentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileExtension,
    required this.storagePath,
    required this.uploadedBy,
    required this.uploadedAt,
    this.parentFolderId,
    this.isFolder = false,
    String? fileType,
  }) : fileType =
           fileType ??
           _inferFileType(fileExtension: fileExtension, isFolder: isFolder);

  factory EventDocumentModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    final uploadedAt = map['uploadedAt'];

    return EventDocumentModel(
      id: documentId,
      fileName: map['fileName'] as String? ?? '',
      fileUrl: map['fileUrl'] as String? ?? '',
      fileExtension: map['fileExtension'] as String? ?? '',
      storagePath: map['storagePath'] as String? ?? '',
      uploadedBy: map['uploadedBy'] as String? ?? 'Unknown',
      uploadedAt: uploadedAt is Timestamp
          ? uploadedAt.toDate()
          : uploadedAt is DateTime
          ? uploadedAt
          : DateTime.fromMillisecondsSinceEpoch(0),
      parentFolderId: map['parentFolderId'] as String?,
      isFolder: map['isFolder'] as bool? ?? false,
      fileType:
          map['fileType'] as String? ??
          _inferFileType(
            fileExtension: map['fileExtension'] as String? ?? '',
            isFolder: map['isFolder'] as bool? ?? false,
          ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileExtension': fileExtension,
      'storagePath': storagePath,
      'uploadedBy': uploadedBy,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'parentFolderId': parentFolderId,
      'isFolder': isFolder,
      'fileType': fileType,
    };
  }

  static String inferFileTypeFromExtension(String extension) {
    return _inferFileType(fileExtension: extension, isFolder: false);
  }

  static String _inferFileType({
    required String fileExtension,
    required bool isFolder,
  }) {
    if (isFolder) return 'folder';

    switch (fileExtension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
        return 'video';
      default:
        return 'document';
    }
  }
}
