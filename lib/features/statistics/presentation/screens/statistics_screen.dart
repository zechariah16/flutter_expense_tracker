import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/month_selector.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../dashboard/presentation/widgets/monthly_summary_card.dart';
import '../../../transactions/domain/transaction_calculator.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/transactions_gate.dart';
import '../providers/statistics_providers.dart';
import '../widgets/category_spending_list.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: TransactionsGate(builder: (_) => const _StatisticsBody()),
    );
  }
}

class _StatisticsBody extends ConsumerWidget {
  const _StatisticsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final summary = ref.watch(monthSummaryProvider);
    final spending = ref.watch(categorySpendingProvider);
    final comparison = ref.watch(monthComparisonProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 96),
      children: [
        MonthSelector(
          month: month,
          onChanged: ref.read(selectedMonthProvider.notifier).select,
        ),
        MonthlySummaryCard(summary: summary),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'Compared with ${DateFormatter.month(month.previous)}',
          child: Column(
            children: [
              _ComparisonRow(
                label: 'Income',
                current: comparison.current.income,
                previous: comparison.previous.income,
                higherIsBetter: true,
              ),
              const SizedBox(height: AppSpacing.md),
              _ComparisonRow(
                label: 'Expenses',
                current: comparison.current.expenses,
                previous: comparison.previous.expenses,
                higherIsBetter: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'Spending by category',
          child: CategorySpendingList(items: spending),
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.higherIsBetter,
  });

  final String label;
  final int current;
  final int previous;
  final bool higherIsBetter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final delta = current - previous;
    final percent = TransactionCalculator.percentChange(current, previous);

    final Color color;
    if (delta == 0) {
      color = theme.colorScheme.onSurfaceVariant;
    } else if ((delta > 0) == higherIsBetter) {
      color = AppColors.income(context);
    } else {
      color = AppColors.expense(context);
    }

    final sign = delta > 0 ? '+' : (delta < 0 ? '-' : '');
    final deltaText = delta == 0
        ? 'No change'
        : '$sign${Money.format(delta.abs())}'
            '${percent == null ? '' : ' (${percent > 0 ? '+' : ''}$percent%)'}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(
                '${Money.format(current)} now • ${Money.format(previous)} before',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          deltaText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
