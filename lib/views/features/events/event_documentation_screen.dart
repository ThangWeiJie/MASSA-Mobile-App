import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:massa/models/event_document_model.dart';
import 'package:massa/view_models/features/events/event_documentation_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDocumentationScreen extends StatelessWidget {
  const EventDocumentationScreen({super.key});

  static const Color _backgroundColor = Color(0xFFFFFBF0);
  static const Color _primaryRed = Color(0xFFCE1126);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventDocumentationViewModel>();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final handledByFolder =
                context.read<EventDocumentationViewModel>().goBackFolder();

            if (!handledByFolder) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          viewModel.currentFolderName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _primaryRed,
        foregroundColor: Colors.white,
        onPressed: viewModel.isLoading
            ? null
            : () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<EventDocumentModel>>(
            stream: viewModel.documentsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                final message = _friendlyErrorMessage(snapshot.error);

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                );
              }

              final documents = snapshot.data ?? [];

              if (documents.isEmpty) {
                return _EmptyDocumentationState(
                  isInsideFolder: viewModel.isInsideFolder,
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemBuilder: (context, index) {
                  return _DocumentListItem(document: documents[index]);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: documents.length,
              );
            },
          ),
          if (viewModel.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.18),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  String _friendlyErrorMessage(Object? error) {
    final errorText = error.toString().toLowerCase();

    if (errorText.contains('permission-denied')) {
      return 'Documentation is not available yet.\nPlease update the Firestore permissions for event documents.';
    }

    return 'Unable to load documents.\nPlease try again later.';
  }

  Future<void> _showAddOptions(BuildContext context) async {
    final selectedAction = await showModalBottomSheet<_AddAction>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.create_new_folder),
                title: const Text('Create folder'),
                onTap: () => Navigator.of(context).pop(_AddAction.folder),
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload file'),
                onTap: () => Navigator.of(context).pop(_AddAction.file),
              ),
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
        ? 'Document uploaded successfully.'
        : context.read<EventDocumentationViewModel>().errorMessage ??
            'Upload cancelled.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

    final message = success
        ? 'Folder created.'
        : context.read<EventDocumentationViewModel>().errorMessage ??
            'Could not create folder.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _EmptyDocumentationState extends StatelessWidget {
  const _EmptyDocumentationState({required this.isInsideFolder});

  final bool isInsideFolder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open, size: 54, color: Colors.black38),
            const SizedBox(height: 14),
            Text(
              isInsideFolder
                  ? 'This folder is empty.'
                  : 'No documents uploaded yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentListItem extends StatelessWidget {
  const _DocumentListItem({required this.document});

  final EventDocumentModel document;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('d MMM y, h:mm a').format(document.uploadedAt);
    final subtitle = document.isFolder
        ? 'Folder - Created by ${document.uploadedBy}'
        : 'Uploaded by ${document.uploadedBy} - $dateText';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => _openItem(context),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFCE1126).withValues(alpha: 0.1),
          foregroundColor: const Color(0xFFCE1126),
          child: Icon(
            document.isFolder
                ? Icons.folder
                : _iconForExtension(document.fileExtension),
          ),
        ),
        title: Text(
          document.fileName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        trailing: PopupMenuButton<_DocumentAction>(
          icon: const Icon(Icons.more_vert),
          onSelected: (action) => _handleAction(context, action),
          itemBuilder: (context) {
            return [
              if (!document.isFolder)
                const PopupMenuItem(
                  value: _DocumentAction.open,
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new),
                      SizedBox(width: 12),
                      Text('Open'),
                    ],
                  ),
                ),
              if (!document.isFolder)
                const PopupMenuItem(
                  value: _DocumentAction.copyLink,
                  child: Row(
                    children: [
                      Icon(Icons.link),
                      SizedBox(width: 12),
                      Text('Copy link'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: _DocumentAction.rename,
                child: Row(
                  children: [
                    Icon(Icons.drive_file_rename_outline),
                    SizedBox(width: 12),
                    Text('Rename'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: _DocumentAction.delete,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Color(0xFFCE1126)),
                    SizedBox(width: 12),
                    Text('Delete'),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  static IconData _iconForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _handleAction(
    BuildContext context,
    _DocumentAction action,
  ) async {
    switch (action) {
      case _DocumentAction.open:
        await _openItem(context);
        return;
      case _DocumentAction.copyLink:
        await Clipboard.setData(ClipboardData(text: document.fileUrl));

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document link copied.')),
        );
        return;
      case _DocumentAction.rename:
        await _renameItem(context);
        return;
      case _DocumentAction.delete:
        await _deleteItem(context);
        return;
    }
  }

  Future<void> _openItem(BuildContext context) async {
    if (document.isFolder) {
      context.read<EventDocumentationViewModel>().openFolder(document);
      return;
    }

    final fileUri = Uri.tryParse(document.fileUrl);
    if (fileUri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This document link is invalid.')),
      );
      return;
    }

    final opened = await launchUrl(
      fileUri,
      mode: LaunchMode.externalApplication,
    );

    if (!context.mounted) return;

    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this document.')),
      );
    }
  }

  Future<void> _renameItem(BuildContext context) async {
    final newName = await _showNameDialog(
      context: context,
      title: document.isFolder ? 'Rename folder' : 'Rename file',
      labelText: 'Name',
      initialValue: document.fileName,
      confirmText: 'Rename',
    );

    if (!context.mounted || newName == null) return;

    final success =
        await context.read<EventDocumentationViewModel>().renameDocument(
              document: document,
              newName: newName,
            );

    if (!context.mounted) return;

    final message = success
        ? 'Renamed successfully.'
        : context.read<EventDocumentationViewModel>().errorMessage ??
            'Could not rename item.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _deleteItem(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(document.isFolder ? 'Delete folder?' : 'Delete file?'),
          content: Text(
            document.isFolder
                ? 'This will delete the folder and everything inside it.'
                : 'This file will be removed from documentation.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFCE1126)),
              ),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirmed != true) return;

    final success =
        await context.read<EventDocumentationViewModel>().deleteDocument(
              document,
            );

    if (!context.mounted) return;

    final message = success
        ? 'Deleted successfully.'
        : context.read<EventDocumentationViewModel>().errorMessage ??
            'Could not delete item.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

enum _AddAction { folder, file }

enum _DocumentAction { open, copyLink, rename, delete }

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
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(widget.confirmText),
        ),
      ],
    );
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }
}
