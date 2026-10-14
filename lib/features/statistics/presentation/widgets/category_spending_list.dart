import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/money/money.dart';
import '../../../../core/widgets/category_avatar.dart';
import '../../../categories/domain/category_catalog.dart';
import '../../../transactions/domain/transaction_calculator.dart';

/// Expense breakdown built from plain Flutter widgets (no chart package).
/// Percentages are relative to the month's total expenses, even when
/// [limit] hides the smaller categories.
class CategorySpendingList extends StatelessWidget {
  const CategorySpendingList({super.key, required this.items, this.limit});

  final List<CategorySpend> items;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return Text(
        'No expenses recorded this month.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final total = items.fold<int>(0, (sum, i) => sum + i.amountInMinorUnits);
    final shown = limit == null ? items : items.take(limit!).toList();

    return Column(
      children: [
        for (final item in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _SpendRow(item: item, total: total),
          ),
      ],
    );
  }
}

class _SpendRow extends StatelessWidget {
  const _SpendRow({required this.item, required this.total});

  final CategorySpend item;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = CategoryCatalog.byId(item.categoryId);
    final fraction = item.amountInMinorUnits / total;
    final percent = (fraction * 100).round();

    return Row(
      children: [
        CategoryAvatar(category: category, size: 36),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    Money.format(item.amountInMinorUnits),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 8,
                  color: category.color,
                  backgroundColor: category.color.withValues(alpha: 0.14),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$percent%',
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
