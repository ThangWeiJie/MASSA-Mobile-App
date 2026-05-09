import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:massa/models/event_document_model.dart';

class EventDocumentationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  EventDocumentationRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _documentationCollection(
    String eventId,
  ) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('documentation');
  }

  Future<({String downloadUrl, String storagePath})> uploadFile({
    required String eventId,
    required String fileName,
    required Uint8List fileBytes,
    String? parentFolderId,
    String? contentType,
  }) async {
    final safeFileName = _sanitizeFileName(fileName);
    final folderSegment = parentFolderId == null ? 'root' : parentFolderId;
    final storagePath =
        'event_docs/$eventId/$folderSegment/${DateTime.now().millisecondsSinceEpoch}_$safeFileName';
    final fileRef = _storage.ref().child(storagePath);

    final metadata = SettableMetadata(contentType: contentType);
    final uploadTask = await fileRef.putData(fileBytes, metadata);

    return (
      downloadUrl: await uploadTask.ref.getDownloadURL(),
      storagePath: storagePath,
    );
  }

  Future<void> saveDocumentMetadata({
    required String eventId,
    required EventDocumentModel document,
  }) async {
    final docRef = _documentationCollection(eventId).doc();

    final documentWithFirestoreId = EventDocumentModel(
      id: docRef.id,
      fileName: document.fileName,
      fileUrl: document.fileUrl,
      fileExtension: document.fileExtension,
      storagePath: document.storagePath,
      uploadedBy: document.uploadedBy,
      uploadedAt: document.uploadedAt,
      parentFolderId: document.parentFolderId,
      isFolder: document.isFolder,
    );

    await docRef.set(documentWithFirestoreId.toMap());
  }

  Future<void> createFolder({
    required String eventId,
    required String folderName,
    required String uploadedBy,
    String? parentFolderId,
  }) async {
    final trimmedName = folderName.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Folder name cannot be empty.');
    }

    final folder = EventDocumentModel(
      id: '',
      fileName: trimmedName,
      fileUrl: '',
      fileExtension: '',
      storagePath: '',
      uploadedBy: uploadedBy,
      uploadedAt: DateTime.now(),
      parentFolderId: parentFolderId,
      isFolder: true,
    );

    await saveDocumentMetadata(eventId: eventId, document: folder);
  }

  Future<void> renameDocument({
    required String eventId,
    required String documentId,
    required String newName,
  }) async {
    final trimmedName = newName.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty.');
    }

    await _documentationCollection(eventId).doc(documentId).update({
      'fileName': trimmedName,
    });
  }

  Future<void> deleteDocument({
    required String eventId,
    required EventDocumentModel document,
  }) async {
    if (document.isFolder) {
      await _deleteFolderContents(eventId: eventId, folderId: document.id);
    } else if (document.storagePath.isNotEmpty) {
      await _deleteStorageFile(document.storagePath);
    }

    await _documentationCollection(eventId).doc(document.id).delete();
  }

  Stream<List<EventDocumentModel>> streamDocuments(
    String eventId, {
    String? parentFolderId,
  }) {
    return _documentationCollection(eventId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final documents = snapshot.docs.map((doc) {
        return EventDocumentModel.fromMap(doc.data(), doc.id);
      }).where((document) {
        return document.parentFolderId == parentFolderId;
      }).toList();

      documents.sort((first, second) {
        if (first.isFolder != second.isFolder) {
          return first.isFolder ? -1 : 1;
        }

        return second.uploadedAt.compareTo(first.uploadedAt);
      });

      return documents;
    });
  }

  Future<void> _deleteFolderContents({
    required String eventId,
    required String folderId,
  }) async {
    final children = await _documentationCollection(eventId)
        .where('parentFolderId', isEqualTo: folderId)
        .get();

    for (final childDoc in children.docs) {
      final child = EventDocumentModel.fromMap(childDoc.data(), childDoc.id);
      await deleteDocument(eventId: eventId, document: child);
    }
  }

  Future<void> _deleteStorageFile(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        rethrow;
      }
    }
  }

  String _sanitizeFileName(String fileName) {
    final trimmed = fileName.trim();
    final normalized = trimmed.isEmpty ? 'document' : trimmed;
    return normalized.replaceAll(RegExp(r'[\\/#?%*:|"<>]'), '_');
  }
}
