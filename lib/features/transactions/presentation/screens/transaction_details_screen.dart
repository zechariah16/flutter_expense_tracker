import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/category_avatar.dart';
import '../../../categories/domain/category_catalog.dart';
import '../../data/transaction_repository.dart';
import '../../domain/transaction.dart';
import '../providers/transaction_providers.dart';
import 'transaction_form_screen.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  const TransactionDetailsScreen({super.key, required this.transactionId});

  final String transactionId;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MoneyTransaction transaction,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(transactionsProvider.notifier);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('"${transaction.title}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await notifier.remove(transaction.id);
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Transaction deleted')));
    } catch (e) {
      final message =
          e is RepositoryException ? e.message : 'Could not delete. Please try again.';
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaction = ref.watch(transactionByIdProvider(transactionId));
    // Briefly null right after deletion, just before the screen pops.
    if (transaction == null) return const Scaffold();

    final theme = Theme.of(context);
    final category = CategoryCatalog.byId(transaction.categoryId);
    final color = transaction.isIncome
        ? AppColors.income(context)
        : AppColors.expense(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => openTransactionForm(context, existing: transaction),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, ref, transaction),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  CategoryAvatar(category: category, size: 56),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    Money.formatSigned(
                      transaction.amountInMinorUnits,
                      isIncome: transaction.isIncome,
                    ),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    transaction.title,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Type', value: transaction.type.label),
                  _DetailRow(label: 'Category', value: category.name),
                  _DetailRow(label: 'Date', value: DateFormatter.day(transaction.date)),
                  _DetailRow(
                    label: 'Created',
                    value: DateFormatter.dateTime(transaction.createdAt),
                  ),
                  _DetailRow(
                    label: 'Last updated',
                    value: DateFormatter.dateTime(transaction.updatedAt),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
