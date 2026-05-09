import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:massa/models/event_document_model.dart'; //
import 'package:massa/view_models/features/events/event_documentation_viewmodel.dart'; //
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDocumentationScreen extends StatelessWidget {
  const EventDocumentationScreen({super.key});

  // MASSA Theme Colors
  static const Color _backgroundColor = Color(0xFFFFFBF0);
  static const Color _massaBrown = Colors.brown; 
  static const Color _massaOrange = Color(0xFFEA580C); 

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EventDocumentationViewModel>(); //

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: _massaBrown,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            final handledByFolder =
                context.read<EventDocumentationViewModel>().goBackFolder(); //

            if (!handledByFolder) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          viewModel.currentFolderName, //
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      // Fixed: Padded to sit above the Bottom Navigation Bar
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110.0), 
        child: FloatingActionButton(
          backgroundColor: _massaOrange,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: viewModel.isLoading
              ? null
              : () => _showAddOptions(context), //
          child: const Icon(Icons.add, size: 30),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<EventDocumentModel>>(
            stream: viewModel.documentsStream, //
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _massaOrange));
              }

              if (snapshot.hasError) {
                final message = _friendlyErrorMessage(snapshot.error); //
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _massaBrown, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }

              final documents = snapshot.data ?? [];

              if (documents.isEmpty) {
                return _EmptyDocumentationState(
                  isInsideFolder: viewModel.isInsideFolder, //
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 130), 
                itemBuilder: (context, index) {
                  return _DocumentListItem(document: documents[index]); //
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: documents.length,
              );
            },
          ),
          if (viewModel.isLoading) //
            Container(
              color: Colors.black.withOpacity(0.18),
              child: const Center(child: CircularProgressIndicator(color: _massaOrange)),
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
                leading: const Icon(Icons.create_new_folder, color: _massaBrown),
                title: const Text('Create folder', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.of(context).pop(_AddAction.folder),
              ),
              ListTile(
                leading: const Icon(Icons.upload_file, color: _massaBrown),
                title: const Text('Upload file', style: TextStyle(fontWeight: FontWeight.w600)),
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
    final success = await context.read<EventDocumentationViewModel>().pickAndUploadDocument(); //
    if (!context.mounted) return;
    final message = success ? 'Document uploaded successfully.' : 'Upload failed or cancelled.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
    final success = await context.read<EventDocumentationViewModel>().createFolder(folderName: folderName); //
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Folder created.' : 'Could not create folder.')));
  }
}

// --- List Items and Sub-widgets ---

class _DocumentListItem extends StatelessWidget {
  const _DocumentListItem({required this.document});
  final EventDocumentModel document;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('d MMM y').format(document.uploadedAt);
    final viewModel = context.read<EventDocumentationViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => _openItem(context),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (document.isFolder ? Colors.orange : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            document.isFolder ? Icons.folder_rounded : _iconForExtension(document.fileExtension),
            color: document.isFolder ? Colors.orange[800] : Colors.red[800],
          ),
        ),
        title: Text(document.fileName, style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        subtitle: Text('By ${document.uploadedBy} • $dateText', style: const TextStyle(fontSize: 12)),
        trailing: PopupMenuButton<_DocumentAction>(
          icon: const Icon(Icons.more_vert, color: Colors.brown),
          onSelected: (action) => _handleAction(context, action),
          itemBuilder: (context) => [
            if (!document.isFolder) const PopupMenuItem(value: _DocumentAction.open, child: Text('Open')),
            const PopupMenuItem(value: _DocumentAction.rename, child: Text('Rename')),
            const PopupMenuItem(value: _DocumentAction.delete, child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  static IconData _iconForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'jpg': case 'jpeg': case 'png': return Icons.image;
      case 'doc': case 'docx': return Icons.description;
      case 'xls': case 'xlsx': return Icons.table_chart;
      default: return Icons.insert_drive_file;
    }
  }

  Future<void> _openItem(BuildContext context) async {
    if (document.isFolder) {
      context.read<EventDocumentationViewModel>().openFolder(document); //
      return;
    }
    final uri = Uri.tryParse(document.fileUrl);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _handleAction(BuildContext context, _DocumentAction action) async {
    final viewModel = context.read<EventDocumentationViewModel>();
    if (action == _DocumentAction.delete) {
      await viewModel.deleteDocument(document); //
    } else if (action == _DocumentAction.rename) {
      final name = await _showNameDialog(context: context, title: 'Rename', labelText: 'Name', initialValue: document.fileName, confirmText: 'Rename');
      if (name != null) await viewModel.renameDocument(document: document, newName: name); //
    } else if (action == _DocumentAction.open) {
      _openItem(context);
    }
  }
}

class _EmptyDocumentationState extends StatelessWidget {
  const _EmptyDocumentationState({required this.isInsideFolder});
  final bool isInsideFolder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.brown.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            isInsideFolder ? 'This folder is empty.' : 'No documents uploaded yet.',
            style: const TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Enum and Dialog Helpers
enum _AddAction { folder, file }
enum _DocumentAction { open, rename, delete }

Future<String?> _showNameDialog({
  required BuildContext context,
  required String title,
  required String labelText,
  required String initialValue,
  required String confirmText,
}) async {
  return showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(title: title, labelText: labelText, initialValue: initialValue, confirmText: confirmText),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.labelText, required this.initialValue, required this.confirmText});
  final String title, labelText, initialValue, confirmText;
  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller;
  @override
  void initState() { super.initState(); _controller = TextEditingController(text: widget.initialValue); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(controller: _controller, autofocus: true, decoration: InputDecoration(labelText: widget.labelText)),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(context).pop(_controller.text.trim()), child: Text(widget.confirmText)),
      ],
    );
  }
}