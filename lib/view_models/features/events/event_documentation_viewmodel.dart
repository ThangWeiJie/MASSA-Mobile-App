import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:massa/models/event_document_model.dart';
import 'package:massa/repository/event_documentation_repository.dart';

class EventDocumentationViewModel extends ChangeNotifier {
  final EventDocumentationRepository repository;
  final String eventId;

  EventDocumentationViewModel({
    required this.repository,
    required this.eventId,
  });

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentFolderId;
  final List<EventDocumentModel> _folderStack = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentFolderId => _currentFolderId;
  bool get isInsideFolder => _currentFolderId != null;
  String get currentFolderName =>
      _folderStack.isEmpty ? 'Event Documentation' : _folderStack.last.fileName;

  Stream<List<EventDocumentModel>> get documentsStream {
    return repository.streamDocuments(eventId, parentFolderId: _currentFolderId);
  }

  Future<bool> pickAndUploadDocument({
    String uploadedBy = 'EXCO Test User',
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await FilePicker.platform.pickFiles(withData: true);

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final pickedFile = result.files.single;
      final fileBytes = pickedFile.bytes;

      if (fileBytes == null) {
        throw Exception('Could not read the selected file.');
      }

      final fileName = pickedFile.name;
      final fileExtension = pickedFile.extension?.toLowerCase() ?? '';
      final uploadResult = await repository.uploadFile(
        eventId: eventId,
        fileName: fileName,
        fileBytes: fileBytes,
        parentFolderId: _currentFolderId,
      );

      final document = EventDocumentModel(
        id: '',
        fileName: fileName,
        fileUrl: uploadResult.downloadUrl,
        fileExtension: fileExtension,
        storagePath: uploadResult.storagePath,
        uploadedBy: uploadedBy,
        uploadedAt: DateTime.now(),
        parentFolderId: _currentFolderId,
      );

      await repository.saveDocumentMetadata(
        eventId: eventId,
        document: document,
      );

      return true;
    } catch (e) {
      _errorMessage = 'Failed to upload document: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createFolder({
    required String folderName,
    String uploadedBy = 'EXCO Test User',
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.createFolder(
        eventId: eventId,
        folderName: folderName,
        uploadedBy: uploadedBy,
        parentFolderId: _currentFolderId,
      );

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create folder: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> renameDocument({
    required EventDocumentModel document,
    required String newName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.renameDocument(
        eventId: eventId,
        documentId: document.id,
        newName: newName,
      );

      final stackIndex = _folderStack.indexWhere((item) => item.id == document.id);
      if (stackIndex != -1) {
        _folderStack[stackIndex] = EventDocumentModel(
          id: document.id,
          fileName: newName.trim(),
          fileUrl: document.fileUrl,
          fileExtension: document.fileExtension,
          storagePath: document.storagePath,
          uploadedBy: document.uploadedBy,
          uploadedAt: document.uploadedAt,
          parentFolderId: document.parentFolderId,
          isFolder: document.isFolder,
        );
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to rename item: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDocument(EventDocumentModel document) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.deleteDocument(eventId: eventId, document: document);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete item: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void openFolder(EventDocumentModel folder) {
    if (!folder.isFolder) return;

    _folderStack.add(folder);
    _currentFolderId = folder.id;
    notifyListeners();
  }

  bool goBackFolder() {
    if (_folderStack.isEmpty) return false;

    _folderStack.removeLast();
    _currentFolderId = _folderStack.isEmpty ? null : _folderStack.last.id;
    notifyListeners();
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
