import 'package:flutter/material.dart';

import '../utils/date_formatter.dart';
import '../utils/month.dart';

/// Previous / next month control. Cannot go past the current month.
class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key, required this.month, required this.onChanged});

  final Month month;
  final ValueChanged<Month> onChanged;

  @override
  Widget build(BuildContext context) {
    final canGoNext = !month.next.isAfter(Month.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous month',
          onPressed: () => onChanged(month.previous),
        ),
        Text(
          DateFormatter.month(month),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next month',
          onPressed: canGoNext ? () => onChanged(month.next) : null,
        ),
      ],
    );
  }
}
