import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../transactions/domain/transaction.dart';
import '../../../transactions/domain/transaction_calculator.dart';
import '../../../transactions/domain/transaction_filter.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

/// All-time balance. Deliberately independent of the selected month.
final allTimeBalanceProvider = Provider<int>((ref) {
  return TransactionCalculator.balance(ref.watch(transactionListProvider));
});

final recentTransactionsProvider = Provider<List<MoneyTransaction>>((ref) {
  return const TransactionFilter()
      .apply(ref.watch(transactionListProvider))
      .take(AppConstants.recentTransactionsLimit)
      .toList();
});
