import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/customers/customer_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';

/// CustomersScreen — list of the active business's customers.
class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

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
          const Center(child: CircularProgressIndicator()),
        CustomerViewStatus.failure => Center(child: Text(l10n.customerError)),
        CustomerViewStatus.loaded when state.customers.isEmpty => _EmptyState(
          icon: Icons.people_outline,
          message: l10n.customersEmpty,
        ),
        CustomerViewStatus.loaded => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.customers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final customer = state.customers[index];
            return _CustomerTile(
              customer: customer,
              onTap: () =>
                  context.push(RouteNames.customerEdit, extra: customer),
            );
          },
        ),
      },
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer, required this.onTap});

  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
