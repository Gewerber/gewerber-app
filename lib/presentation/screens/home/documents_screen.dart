import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/documents/documents_cubit.dart';
import 'package:gewerber_app/application/documents/documents_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// DocumentsScreen — all files stored for the business (receipts, logos,
/// attachments, generated invoice PDFs) with upload and download.
class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.documentsTitle)),
      body: const SafeArea(child: DocumentsView()),
    );
  }
}

/// Body of the documents overview. Rendered standalone by
/// [DocumentsScreen] and inline inside the settings master-detail pane.
class DocumentsView extends StatefulWidget {
  const DocumentsView({super.key});

  @override
  State<DocumentsView> createState() => _DocumentsViewState();
}

class _DocumentsViewState extends State<DocumentsView> {
  @override
  void initState() {
    super.initState();
    final documents = context.read<DocumentsCubit>();
    if (documents.state.status == DocumentsViewStatus.initial) {
      documents.load();
    }
  }

  Future<void> _upload() async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DocumentsCubit>();
    final business = context.read<BusinessCubit>().state.activeBusiness;
    if (business == null) return;

    final file = await cubit.pickFile();
    if (!mounted || file == null) return;
    // The server rejects anything larger; fail fast with a clear message.
    if (file.sizeBytes > documentMaxSizeBytes) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.documentsFileTooLarge)));
      return;
    }

    final uploaded = await cubit.upload(
      businessId: business.id,
      file: file,
      kind: DocumentKind.attachment,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          uploaded == null ? l10n.documentsUploadError : l10n.documentsUploaded,
        ),
      ),
    );
  }

  Future<void> _download(BusinessDocument document) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<DocumentsCubit>();
    final downloaded = await cubit.download(document);
    if (!mounted) return;
    if (downloaded == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.documentsDownloadError)));
      return;
    }
    final name = downloaded.fileName;
    final dotIndex = name.lastIndexOf('.');
    await FileSaver.instance.saveFile(
      name: dotIndex > 0 ? name.substring(0, dotIndex) : name,
      bytes: Uint8List.fromList(downloaded.bytes),
      fileExtension: dotIndex > 0 ? name.substring(dotIndex + 1) : 'bin',
      mimeType: MimeType.other,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.documentsDownloaded)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<DocumentsCubit>().state;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: switch (state.status) {
          DocumentsViewStatus.initial || DocumentsViewStatus.loading =>
            const Center(child: CircularProgressIndicator()),
          DocumentsViewStatus.failure => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.documentsLoadError),
                const SizedBox(height: GewerberTokens.space12),
                OutlinedButton.icon(
                  onPressed: () => context.read<DocumentsCubit>().load(),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
          DocumentsViewStatus.loaded => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: state.isUploading ? null : _upload,
                  icon: state.isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file_outlined),
                  label: Text(l10n.documentsUploadButton),
                ),
              ),
              const SizedBox(height: GewerberTokens.space16),
              if (state.documents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: GewerberTokens.space24,
                  ),
                  child: Text(
                    l10n.documentsEmpty,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (final document in state.documents) ...[
                  _DocumentTile(
                    document: document,
                    onDownload: () => _download(document),
                  ),
                  const SizedBox(height: GewerberTokens.space8),
                ],
            ],
          ),
        },
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document, required this.onDownload});

  final BusinessDocument document;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(_kindIcon(document.kind)),
        title: Text(
          document.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            _kindLabel(l10n, document.kind),
            if (document.sizeBytes != null) formatFileSize(document.sizeBytes!),
            if (document.createdAt != null) formatDate(document.createdAt!),
          ].join(' · '),
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        trailing: IconButton(
          tooltip: l10n.documentsDownloadButton,
          icon: const Icon(Icons.download_outlined),
          onPressed: onDownload,
        ),
      ),
    );
  }

  IconData _kindIcon(DocumentKind kind) {
    return switch (kind) {
      DocumentKind.invoicePdf => Icons.picture_as_pdf_outlined,
      DocumentKind.receipt => Icons.receipt_outlined,
      DocumentKind.logo => Icons.image_outlined,
      DocumentKind.attachment => Icons.attach_file_outlined,
      DocumentKind.other => Icons.description_outlined,
    };
  }

  String _kindLabel(AppLocalizations l10n, DocumentKind kind) {
    return switch (kind) {
      DocumentKind.invoicePdf => l10n.documentsKindInvoicePdf,
      DocumentKind.receipt => l10n.documentsKindReceipt,
      DocumentKind.logo => l10n.documentsKindLogo,
      DocumentKind.attachment => l10n.documentsKindAttachment,
      DocumentKind.other => l10n.documentsKindOther,
    };
  }
}
