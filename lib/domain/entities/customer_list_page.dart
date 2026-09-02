import 'package:equatable/equatable.dart';

import 'package:gewerber_app/domain/entities/customer.dart';

/// Offset-based paged result for customers.
class CustomerListPage extends Equatable {
  const CustomerListPage({
    required this.items,
    required this.totalCount,
    required this.limit,
    required this.offset,
  });

  final List<Customer> items;
  final int totalCount;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [items, totalCount, limit, offset];
}

/// Cursor-based paged result for customers.
class CustomerCursorPage extends Equatable {
  const CustomerCursorPage({
    required this.items,
    required this.limit,
    this.nextCursor,
  });

  final List<Customer> items;
  final String? nextCursor;
  final int limit;

  @override
  List<Object?> get props => [items, nextCursor, limit];
}
