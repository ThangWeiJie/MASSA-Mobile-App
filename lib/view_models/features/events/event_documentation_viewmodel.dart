import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:massa/models/event_document_model.dart';
import 'package:massa/repository/event_documentation_repository.dart';

class EventDocumentationViewModel extends ChangeNotifier {
  final EventDocumentationRepository repository;
  final String eventId;
  final String? userName;

  bool _isLoading = false;
  bool _isLoadingDocuments = true;
  bool _isLoadingGallery = true;
  String? _errorMessage;
  String? _documentsErrorMessage;
  String? _galleryErrorMessage;
  String? _currentFolderId;
  StreamSubscription<List<EventDocumentModel>>? _documentsSubscription;
  StreamSubscription<List<EventDocumentModel>>? _gallerySubscription;
  final List<EventDocumentModel> _folderStack = [];
  List<EventDocumentModel> _documentFiles = [];
  List<EventDocumentModel> _mediaFiles = [];

  bool get isLoading => _isLoading;
  bool get isLoadingDocuments => _isLoadingDocuments;
  bool get isLoadingGallery => _isLoadingGallery;
  bool get isLoadingFiles => _isLoadingDocuments || _isLoadingGallery;
  String? get errorMessage =>
      _errorMessage ?? _documentsErrorMessage ?? _galleryErrorMessage;
  String? get documentsErrorMessage => _documentsErrorMessage;
  String? get galleryErrorMessage => _galleryErrorMessage;
  String? get currentFolderId => _currentFolderId;
  bool get isInsideFolder => _currentFolderId != null;
  List<EventDocumentModel> get documentFiles => _documentFiles;
  List<EventDocumentModel> get mediaFiles => _mediaFiles;
  String get currentFolderName =>
      _folderStack.isEmpty ? 'Event Documentation' : _folderStack.last.fileName;

  static const List<String> _mediaUploadExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
  ];

  EventDocumentationViewModel({
    required this.repository,
    required this.eventId,
    this.userName,
  }) {
    _subscribeToDocuments();
    _subscribeToGallery();
  }

  Stream<List<EventDocumentModel>> get documentsStream {
    return repository.streamDocuments(
      eventId,
      parentFolderId: _currentFolderId,
    );
  }

  void _subscribeToDocuments() {
    _documentsSubscription?.cancel();
    _isLoadingDocuments = true;
    _documentsErrorMessage = null;

    _documentsSubscription = documentsStream.listen(
      (documents) {
        _documentFiles = documents;
        _isLoadingDocuments = false;
        notifyListeners();
      },
      onError: (error) {
        _documentsErrorMessage = _friendlyErrorMessage(error);
        _documentFiles = [];
        _isLoadingDocuments = false;
        notifyListeners();
      },
    );
  }

  void _subscribeToGallery() {
    _gallerySubscription?.cancel();
    _isLoadingGallery = true;
    _galleryErrorMessage = null;

    _gallerySubscription = repository
        .streamMediaDocuments(eventId)
        .listen(
          (documents) {
            _mediaFiles = documents;
            _isLoadingGallery = false;
            notifyListeners();
          },
          onError: (error) {
            _galleryErrorMessage = _friendlyErrorMessage(error);
            _mediaFiles = [];
            _isLoadingGallery = false;
            notifyListeners();
          },
        );
  }

  String _friendlyErrorMessage(Object? error) {
    final errorText = error.toString().toLowerCase();
    if (errorText.contains('permission-denied')) {
      return 'Documentation is not available yet.\nPlease update the Firestore permissions for event documents.';
    }
    return 'Unable to load documents.\nPlease try again later.';
  }

  Future<bool> pickAndUploadDocument({
    bool useCurrentFolder = true,
    bool mediaOnly = false,
    String? destinationFolderId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: mediaOnly ? FileType.custom : FileType.any,
        allowedExtensions: mediaOnly ? _mediaUploadExtensions : null,
      );

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
      final parentFolderId =
          destinationFolderId ?? (useCurrentFolder ? _currentFolderId : null);
      final uploadResult = await repository.uploadFile(
        eventId: eventId,
        fileName: fileName,
        fileBytes: fileBytes,
        parentFolderId: parentFolderId,
      );

      final document = EventDocumentModel(
        id: '',
        fileName: fileName,
        fileUrl: uploadResult.downloadUrl,
        fileExtension: fileExtension,
        storagePath: uploadResult.storagePath,
        uploadedBy: userName ?? 'Unknown EXCO',
        uploadedAt: DateTime.now(),
        parentFolderId: parentFolderId,
        fileType: EventDocumentModel.inferFileTypeFromExtension(fileExtension),
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
        uploadedBy: userName ?? 'Unknown EXCO',
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

  Future<List<EventDocumentModel>> fetchFolders() {
    return repository.fetchFolders(eventId);
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

      final stackIndex = _folderStack.indexWhere(
        (item) => item.id == document.id,
      );
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
          fileType: document.fileType,
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

  Future<bool> moveDocument({
    required EventDocumentModel document,
    required String? parentFolderId,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await repository.moveDocument(
        eventId: eventId,
        documentId: document.id,
        parentFolderId: parentFolderId,
      );

      return true;
    } catch (e) {
      _errorMessage = 'Failed to move item: $e';
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
    _subscribeToDocuments();
  }

  bool goBackFolder() {
    if (_folderStack.isEmpty) return false;

    _folderStack.removeLast();
    _currentFolderId = _folderStack.isEmpty ? null : _folderStack.last.id;
    _subscribeToDocuments();
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

  @override
  void dispose() {
    _documentsSubscription?.cancel();
    _gallerySubscription?.cancel();
    super.dispose();
  }
}
