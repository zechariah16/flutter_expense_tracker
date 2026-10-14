import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/money/money.dart';

/// All-time balance (income - expenses). Not affected by the month selector.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balanceInMinorUnits});

  final int balanceInMinorUnits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    return Card(
      color: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total balance',
              style: theme.textTheme.titleSmall?.copyWith(
                color: onPrimary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Money.format(balanceInMinorUnits),
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'All-time income minus expenses',
              style: theme.textTheme.bodySmall?.copyWith(
                color: onPrimary.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
