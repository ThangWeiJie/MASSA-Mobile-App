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

  const EventDocumentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileExtension,
    required this.storagePath,
    required this.uploadedBy,
    required this.uploadedAt,
    this.parentFolderId,
    this.isFolder = false,
  });

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
    };
  }
}
