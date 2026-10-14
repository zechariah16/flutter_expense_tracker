import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/transaction.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_form.dart';

/// Opens the add form (or the edit form when [existing] is given).
Future<void> openTransactionForm(BuildContext context, {MoneyTransaction? existing}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: existing == null,
      builder: (_) => TransactionFormScreen(existing: existing),
    ),
  );
}

class TransactionFormScreen extends ConsumerWidget {
  const TransactionFormScreen({super.key, this.existing});

  final MoneyTransaction? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit transaction' : 'Add transaction'),
      ),
      body: SafeArea(
        child: TransactionForm(
          existing: existing,
          onCancel: () => Navigator.of(context).pop(),
          onSubmit: (transaction) async {
            // Capture these before the await so we never use a stale context.
            final notifier = ref.read(transactionsProvider.notifier);
            final navigator = Navigator.of(context);
            final messenger = ScaffoldMessenger.of(context);

            if (isEditing) {
              await notifier.edit(transaction);
            } else {
              await notifier.add(transaction);
            }
            navigator.pop();
            messenger.showSnackBar(
              SnackBar(
                content: Text(isEditing ? 'Transaction updated' : 'Transaction added'),
              ),
            );
          },
        ),
      ),
    );
  }
}
