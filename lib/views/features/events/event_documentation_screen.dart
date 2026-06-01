import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:massa/models/event_document_model.dart';
import 'package:massa/view_models/features/events/event_documentation_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDocumentationScreen extends StatefulWidget {
  const EventDocumentationScreen({super.key});

  static const Color _backgroundColor = Color(0xFFFFFBF0);
  static const Color _primaryRed = Color(0xFFCE1126);
  static const Color _textColor = Color(0xFF3A1F16);

  @override
  State<EventDocumentationScreen> createState() =>
      _EventDocumentationScreenState();
}

class _EventDocumentationScreenState extends State<EventDocumentationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _activeTabIndex = 0;

  bool get _isDocumentsTab => _activeTabIndex == 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_activeTabIndex == _tabController.index) return;

    setState(() {
      _activeTabIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventDocumentationViewModel>();
    final title = _isDocumentsTab
        ? viewModel.currentFolderName
        : 'Event Gallery';

    return Scaffold(
      backgroundColor: EventDocumentationScreen._backgroundColor,
      appBar: AppBar(
        backgroundColor: EventDocumentationScreen._backgroundColor,
        foregroundColor: EventDocumentationScreen._textColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _handleBackPressed(context),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: EventDocumentationScreen._primaryRed,
          indicatorWeight: 3,
          labelColor: EventDocumentationScreen._primaryRed,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(icon: Icon(Icons.description_outlined), text: 'Documents'),
            Tab(icon: Icon(Icons.photo_library_outlined), text: 'Gallery'),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: FloatingActionButton(
          backgroundColor: EventDocumentationScreen._primaryRed,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: viewModel.isLoading ? null : () => _handleFabPressed(context),
          child: Icon(_isDocumentsTab ? Icons.add : Icons.add_photo_alternate),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _DocumentsTab(
                files: viewModel.documentFiles,
                isInsideFolder: viewModel.isInsideFolder,
                isLoading: viewModel.isLoadingDocuments,
                errorMessage: viewModel.documentsErrorMessage,
              ),
              _GalleryTab(
                files: viewModel.mediaFiles,
                isLoading: viewModel.isLoadingGallery,
                errorMessage: viewModel.galleryErrorMessage,
              ),
            ],
          ),
          if (viewModel.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.18),
              child: const Center(
                child: CircularProgressIndicator(
                  color: EventDocumentationScreen._primaryRed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleBackPressed(BuildContext context) {
    if (_isDocumentsTab) {
      final handledByFolder = context
          .read<EventDocumentationViewModel>()
          .goBackFolder();

      if (handledByFolder) return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _handleFabPressed(BuildContext context) async {
    if (_isDocumentsTab) {
      await _showAddOptions(context);
      return;
    }

    await _uploadGalleryMedia(context);
  }

  Future<void> _showAddOptions(BuildContext context) async {
    final selectedAction = await showModalBottomSheet<_AddAction>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.create_new_folder,
                  color: EventDocumentationScreen._primaryRed,
                ),
                title: const Text(
                  'Create folder',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.of(context).pop(_AddAction.folder),
              ),
              ListTile(
                leading: const Icon(
                  Icons.upload_file,
                  color: EventDocumentationScreen._primaryRed,
                ),
                title: const Text(
                  'Upload file',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.of(context).pop(_AddAction.file),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (!context.mounted || selectedAction == null) return;

    switch (selectedAction) {
      case _AddAction.folder:
        await _createFolder(context);
        return;
      case _AddAction.file:
        await _uploadFile(context);
        return;
    }
  }

  Future<void> _uploadFile(BuildContext context) async {
    final success = await context
        .read<EventDocumentationViewModel>()
        .pickAndUploadDocument();
    if (!context.mounted) return;

    final message = success
        ? 'File uploaded successfully.'
        : 'Upload failed or cancelled.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _uploadGalleryMedia(BuildContext context) async {
    final success = await context
        .read<EventDocumentationViewModel>()
        .pickAndUploadDocument(
          useCurrentFolder: false,
          mediaOnly: true,
        );
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Media uploaded to Gallery.'
              : 'Upload failed or cancelled.',
        ),
      ),
    );
  }

  Future<void> _createFolder(BuildContext context) async {
    final folderName = await _showNameDialog(
      context: context,
      title: 'Create folder',
      labelText: 'Folder name',
      initialValue: '',
      confirmText: 'Create',
    );

    if (!context.mounted || folderName == null) return;

    final success = await context
        .read<EventDocumentationViewModel>()
        .createFolder(folderName: folderName);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Folder created.' : 'Could not create folder.')),
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab({
    required this.files,
    required this.isInsideFolder,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<EventDocumentModel> files;
  final bool isInsideFolder;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: EventDocumentationScreen._primaryRed,
        ),
      );
    }

    if (errorMessage != null) {
      return _ErrorState(message: errorMessage!);
    }

    if (files.isEmpty) {
      return _EmptyTabState(
        icon: isInsideFolder
            ? Icons.folder_open_rounded
            : Icons.description_outlined,
        message: isInsideFolder
            ? 'This folder is empty.'
            : 'No documents uploaded yet.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
      itemCount: files.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _DocumentFileRow(document: files[index]);
      },
    );
  }
}

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({
    required this.files,
    required this.isLoading,
    required this.errorMessage,
  });

  final List<EventDocumentModel> files;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: EventDocumentationScreen._primaryRed,
        ),
      );
    }

    if (errorMessage != null) {
      return _ErrorState(message: errorMessage!);
    }

    if (files.isEmpty) {
      return const _EmptyTabState(
        icon: Icons.photo_library_outlined,
        message: 'No media uploaded yet.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        return _MediaTile(media: files[index]);
      },
    );
  }
}

class _DocumentFileRow extends StatelessWidget {
  const _DocumentFileRow({required this.document});

  final EventDocumentModel document;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('d MMM y').format(document.uploadedAt);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openItem(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: EventDocumentationScreen._primaryRed.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  document.isFolder
                      ? Icons.folder_rounded
                      : _iconForExtension(document.fileExtension),
                  color: EventDocumentationScreen._primaryRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: EventDocumentationScreen._textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      document.isFolder
                          ? 'Folder'
                          : 'Uploaded $dateText by ${document.uploadedBy}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_DocumentAction>(
                icon: const Icon(Icons.more_vert, color: Colors.black54),
                onSelected: (action) => _handleAction(context, action),
                itemBuilder: (context) => [
                  if (!document.isFolder)
                    const PopupMenuItem(
                      value: _DocumentAction.open,
                      child: Text('Open'),
                    ),
                  const PopupMenuItem(
                    value: _DocumentAction.rename,
                    child: Text('Rename'),
                  ),
                  const PopupMenuItem(
                    value: _DocumentAction.delete,
                    child: Text(
                      'Delete',
                      style: TextStyle(color: EventDocumentationScreen._primaryRed),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Future<void> _openItem(BuildContext context) async {
    if (document.isFolder) {
      context.read<EventDocumentationViewModel>().openFolder(document);
      return;
    }

    await _launchDocument(document.fileUrl);
  }

  Future<void> _handleAction(
    BuildContext context,
    _DocumentAction action,
  ) async {
    final viewModel = context.read<EventDocumentationViewModel>();

    if (action == _DocumentAction.delete) {
      await viewModel.deleteDocument(document);
      return;
    }

    if (action == _DocumentAction.rename) {
      final name = await _showNameDialog(
        context: context,
        title: 'Rename',
        labelText: 'Name',
        initialValue: document.fileName,
        confirmText: 'Rename',
      );

      if (name != null) {
        await viewModel.renameDocument(document: document, newName: name);
      }
      return;
    }

    await _openItem(context);
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.media});

  final EventDocumentModel media;

  @override
  Widget build(BuildContext context) {
    final isVideo = _isVideo(media.fileExtension);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _launchDocument(media.fileUrl),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isVideo)
                    Container(
                      color: EventDocumentationScreen._textColor.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.videocam_outlined,
                        color: EventDocumentationScreen._primaryRed,
                        size: 32,
                      ),
                    )
                  else
                    Image.network(
                      media.fileUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: EventDocumentationScreen._textColor.withValues(
                          alpha: 0.1,
                        ),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: EventDocumentationScreen._primaryRed,
                        ),
                      ),
                    ),
                  if (isVideo)
                    const Align(
                      alignment: Alignment.center,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.topRight,
                    child: PopupMenuButton<_DocumentAction>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: Colors.white,
                      onSelected: (action) => _handleAction(context, action),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _DocumentAction.open,
                          child: Text('Open'),
                        ),
                        PopupMenuItem(
                          value: _DocumentAction.rename,
                          child: Text('Rename'),
                        ),
                        PopupMenuItem(
                          value: _DocumentAction.delete,
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: EventDocumentationScreen._primaryRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  media.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isVideo(String extension) {
    return {'mp4', 'mov', 'avi', 'mkv', 'webm'}.contains(
      extension.toLowerCase(),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _DocumentAction action,
  ) async {
    final viewModel = context.read<EventDocumentationViewModel>();

    if (action == _DocumentAction.delete) {
      await viewModel.deleteDocument(media);
      return;
    }

    if (action == _DocumentAction.rename) {
      final name = await _showNameDialog(
        context: context,
        title: 'Rename',
        labelText: 'Name',
        initialValue: media.fileName,
        confirmText: 'Rename',
      );

      if (name != null) {
        await viewModel.renameDocument(document: media, newName: name);
      }
      return;
    }

    await _launchDocument(media.fileUrl);
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 72,
            color: EventDocumentationScreen._primaryRed.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: EventDocumentationScreen._textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

enum _AddAction { folder, file }

enum _DocumentAction { open, rename, delete }

Future<void> _launchDocument(String fileUrl) async {
  final uri = Uri.tryParse(fileUrl);
  if (uri != null) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<String?> _showNameDialog({
  required BuildContext context,
  required String title,
  required String labelText,
  required String initialValue,
  required String confirmText,
}) async {
  return showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(
      title: title,
      labelText: labelText,
      initialValue: initialValue,
      confirmText: confirmText,
    ),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.labelText,
    required this.initialValue,
    required this.confirmText,
  });

  final String title;
  final String labelText;
  final String initialValue;
  final String confirmText;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: widget.labelText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
