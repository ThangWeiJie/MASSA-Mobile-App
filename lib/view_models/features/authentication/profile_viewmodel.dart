import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:massa/models/user.dart';
import 'package:massa/repository/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final String userId;

  UserModel? _userModel;
  bool _isLoading = true;
  bool _isUploadingProfileImage = false;
  bool _isDisposed = false;
  String? _errorMessage;

  StreamSubscription<UserModel>? _userSubscription;

  ProfileViewModel({required UserRepository userRepo, required this.userId})
    : _userRepository = userRepo {
    if (userId.isNotEmpty) {
      _listenToUser();
    } else {
      _isLoading = false;
    }
  }

  UserModel? get user => _userModel;
  bool get isLoading => _isLoading;
  bool get isUploadingProfileImage => _isUploadingProfileImage;
  String? get errorMessage => _errorMessage;

  void _listenToUser() {
    _userSubscription = _userRepository
        .getUserStream(userId)
        .listen(
          (updatedUser) {
            _userModel = updatedUser;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Profile sync error: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> fetchUser() async {
    if (userId.isEmpty) {
      _setLoading(false);
      return;
    }

    try {
      _userModel = await _userRepository.getUser(userId);
    } catch (error) {
      debugPrint('Fetch profile error: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String department,
  }) async {
    if (_userModel == null) return;

    _setLoading(true);

    try {
      await _userRepository.updateUserProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        department: department,
      );
    } finally {
      if (!_isDisposed) {
        _setLoading(false);
      }
    }
  }

  Future<bool> pickAndUploadProfileImage() async {
    if (_userModel == null || userId.isEmpty) return false;

    _setUploadingProfileImage(true);
    _errorMessage = null;

    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) return false;

      final pickedFile = result.files.single;
      final fileBytes = pickedFile.bytes;

      if (fileBytes == null) {
        throw Exception('Could not read the selected image.');
      }

      await _userRepository.updateUserProfileImage(
        userId: userId,
        fileName: pickedFile.name,
        fileBytes: fileBytes,
        previousStoragePath: _userModel?.profileImageStoragePath,
        contentType: _contentTypeForExtension(pickedFile.extension),
      );

      return true;
    } catch (error) {
      debugPrint('Profile image upload error: $error');
      _errorMessage = error.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setUploadingProfileImage(false);
    }
  }

  Future<void> adminUpdateUserProfile({
    required String fullName,
    required String phone,
    required String department,
    required String role,
  }) async {
    if (_userModel == null) return;

    _setLoading(true);

    try {
      await _userRepository.adminUpdateUserProfile(
        userId: userId,
        fullName: fullName,
        phone: phone,
        department: department,
        role: role,
      );
    } finally {
      if (!_isDisposed) {
        _setLoading(false);
      }
    }
  }

  void _setLoading(bool value) {
    if (_isDisposed || _isLoading == value) return;
    _isLoading = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  void _setUploadingProfileImage(bool value) {
    if (_isDisposed || _isUploadingProfileImage == value) return;
    _isUploadingProfileImage = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  String? _contentTypeForExtension(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userSubscription?.cancel();
    super.dispose();
  }
}
