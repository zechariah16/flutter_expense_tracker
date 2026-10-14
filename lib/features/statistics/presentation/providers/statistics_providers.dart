import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/domain/transaction_calculator.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

final categorySpendingProvider = Provider<List<CategorySpend>>((ref) {
  return TransactionCalculator.expenseByCategory(
    ref.watch(transactionListProvider),
    ref.watch(selectedMonthProvider),
  );
});

final monthComparisonProvider = Provider<MonthComparison>((ref) {
  final transactions = ref.watch(transactionListProvider);
  final month = ref.watch(selectedMonthProvider);
  return MonthComparison(
    current: TransactionCalculator.summarize(transactions, month),
    previous: TransactionCalculator.summarize(transactions, month.previous),
  );
});
