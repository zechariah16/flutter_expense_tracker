import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../transactions/domain/transaction_calculator.dart';

/// Income, expenses and net cash flow for the selected month.
class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({super.key, required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final income = AppColors.income(context);
    final expense = AppColors.expense(context);
    final netColor = summary.net >= 0 ? income : expense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.arrow_downward,
                    label: 'Income',
                    amount: summary.income,
                    color: income,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _Stat(
                    icon: Icons.arrow_upward,
                    label: 'Expenses',
                    amount: summary.expenses,
                    color: expense,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Net cash flow',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  Money.format(summary.net),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: netColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  Money.format(amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
