import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_filter_bar.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transactions_gate.dart';
import 'transaction_form_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: TransactionsGate(builder: (_) => const _TransactionsBody()),
    );
  }
}

class _TransactionsBody extends ConsumerWidget {
  const _TransactionsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(transactionListProvider);
    final filtered = ref.watch(filteredTransactionsProvider);

    if (all.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No transactions yet',
        message: 'Record your first income or expense to see it here.',
        actionLabel: 'Add transaction',
        onAction: () => openTransactionForm(context),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
          child: TransactionFilterBar(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  title: 'No matching transactions',
                  message: 'Try a different search or clear the filters.',
                  actionLabel: 'Clear filters',
                  onAction: () => ref.read(transactionFilterProvider.notifier).reset(),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    96,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, index) => TransactionTile(transaction: filtered[index]),
                ),
        ),
      ],
    );
  }
}
