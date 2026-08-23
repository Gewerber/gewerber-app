import 'package:gewerber_app/domain/entities/invoice_template.dart';

/// Contract for invoice-template operations used by the application layer.
///
/// The backend exposes no delete: templates are listed, created and edited
/// only (mirrors the customer endpoints).
abstract interface class InvoiceTemplateRepository {
  /// Loads the templates of the active business.
  ///
  /// [limit] and [offset] page through the server-side list; `null` lets the
  /// backend apply its defaults.
  Future<List<InvoiceTemplate>> list({int? limit, int? offset});

  /// Loads a single template by [templateId].
  Future<InvoiceTemplate> get(int templateId);

  /// Creates a new template for the active business.
  ///
  /// When [isDefault] is `true` the server clears the default flag on every
  /// other template of the business.
  Future<InvoiceTemplate> create({
    required String name,
    bool isDefault,
    String? headerText,
    String? footerText,
  });

  /// Persists changes to an existing template.
  ///
  /// When the updated template becomes the default, the server clears the
  /// default flag on every other template of the business.
  Future<InvoiceTemplate> update(InvoiceTemplate template);
}
