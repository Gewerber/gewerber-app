import 'package:equatable/equatable.dart';

/// Reusable invoice layout template, backed by the server's `invoiceTemplate`
/// endpoint.
///
/// A template bundles the texts and branding applied to every invoice that
/// uses it. At most one template per business is marked as default; the
/// server clears the flag on all others when a new one takes over.
class InvoiceTemplate extends Equatable {
  const InvoiceTemplate({
    required this.id,
    required this.name,
    this.isDefault = false,
    this.headerText,
    this.footerText,
    this.logoDocumentId,
  });

  /// Stable server-side identifier.
  final int id;
  final String name;

  /// Whether new invoices preselect this template.
  final bool isDefault;

  /// Optional text shown near the top of every invoice using the template.
  final String? headerText;

  /// Optional text shown near the bottom of every invoice using the template.
  final String? footerText;

  /// Document id of the invoice logo, if any.
  ///
  /// Preserved across edits; uploading logos is not part of this UI yet.
  final int? logoDocumentId;

  InvoiceTemplate copyWith({
    String? name,
    bool? isDefault,
    String? headerText,
    String? footerText,
  }) {
    return InvoiceTemplate(
      id: id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      headerText: headerText ?? this.headerText,
      footerText: footerText ?? this.footerText,
      logoDocumentId: logoDocumentId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    isDefault,
    headerText,
    footerText,
    logoDocumentId,
  ];
}
