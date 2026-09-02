import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/customers/customer_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/shimmer_loader.dart';
import 'package:gewerber_app/presentation/widgets/common/staggered_list_item.dart';

/// CustomersScreen — searchable list of the active business's customers.
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // The invoicing module usually has loaded the customers already; make
    // sure they are present when this screen is opened directly.
    final cubit = context.read<CustomerCubit>();
    if (cubit.state.status == CustomerViewStatus.initial) {
      cubit.load();
    }
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(Customer customer) {
    if (_query.isEmpty) return true;
    return [
      customer.name,
      customer.companyName,
      customer.email,
    ].whereType<String>().any((value) => value.toLowerCase().contains(_query));
  }

  Future<void> _confirmDelete(Customer customer) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.customerDeleteTitle),
        content: Text(l10n.customerDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.customersArchive),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<CustomerCubit>().archive(customer.id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.customersArchived)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<CustomerCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customersTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.customerNew),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: Text(l10n.customersAdd),
      ),
      body: switch (state.status) {
        CustomerViewStatus.initial || CustomerViewStatus.loading =>
          const Center(child: ShimmerLoader(lines: 5, height: 16)),
        CustomerViewStatus.failure => Center(child: Text(l10n.customerError)),
        CustomerViewStatus.loaded when state.customers.isEmpty => _EmptyState(
          icon: Icons.people_outline,
          message: l10n.customersEmpty,
        ),
        CustomerViewStatus.loaded => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GewerberTokens.space16,
                GewerberTokens.space16,
                GewerberTokens.space16,
                GewerberTokens.space8,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.customersSearchHint,
                  prefixIcon: const Icon(Icons.search_outlined),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_outlined),
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).clearButtonTooltip,
                          onPressed: () => _searchController.clear(),
                        ),
                ),
              ),
            ),
            Expanded(child: _buildList(context, state)),
          ],
        ),
      },
    );
  }

  Widget _buildList(BuildContext context, CustomerState state) {
    final l10n = AppLocalizations.of(context);
    final customers = state.customers.where(_matches).toList();

    if (customers.isEmpty) {
      return _EmptyState(
        icon: Icons.search_off_outlined,
        message: l10n.customersNoResults,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(GewerberTokens.space16),
      itemCount: customers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final customer = customers[index];
        return StaggeredListItem(
          index: index,
          child: _CustomerTile(
            customer: customer,
            onTap: () => context.push(RouteNames.customerEdit, extra: customer),
            onDelete: customer.status == CustomerStatus.active
                ? () => _confirmDelete(customer)
                : null,
          ),
        );
      },
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({
    required this.customer,
    required this.onTap,
    this.onDelete,
  });

  final Customer customer;
  final VoidCallback onTap;

  /// Shows the delete (archive) action when non-null.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final isArchived = customer.status == CustomerStatus.archived;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            isArchived ? Icons.archive_outlined : Icons.person_outline,
            color: colors.onSurfaceVariant,
          ),
        ),
        title: Text(
          customer.displayName,
          style: isArchived ? TextStyle(color: colors.onSurfaceVariant) : null,
        ),
        subtitle: Text(
          [customer.email, customer.phone].whereType<String>().join(' · '),
        ),
        trailing: onDelete == null
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.customerDeleteTitle,
                onPressed: onDelete,
              ),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GewerberTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: colors.outline),
            const SizedBox(height: GewerberTokens.space16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
