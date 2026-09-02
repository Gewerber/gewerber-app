import 'package:equatable/equatable.dart';

import 'package:gewerber_app/domain/entities/invoice.dart';

/// Offset-based paginated result of invoice listings.
class InvoiceListPage extends Equatable {
  const InvoiceListPage({
    required this.items,
    required this.totalCount,
    required this.limit,
    required this.offset,
  });

  final List<Invoice> items;
  final int totalCount;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [items, totalCount, limit, offset];
}

/// Cursor-based paginated result of invoice listings.
class InvoiceCursorPage extends Equatable {
  const InvoiceCursorPage({
    required this.items,
    required this.limit,
    this.nextCursor,
  });

  final List<Invoice> items;
  final String? nextCursor;
  final int limit;

  @override
  List<Object?> get props => [items, nextCursor, limit];
}
