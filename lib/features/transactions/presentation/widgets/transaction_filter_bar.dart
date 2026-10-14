import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../categories/domain/category_catalog.dart';
import '../../domain/transaction_filter.dart';
import '../../domain/transaction_type.dart';
import '../providers/transaction_providers.dart';

class TransactionFilterBar extends ConsumerStatefulWidget {
  const TransactionFilterBar({super.key});

  @override
  ConsumerState<TransactionFilterBar> createState() => _TransactionFilterBarState();
}

class _TransactionFilterBarState extends ConsumerState<TransactionFilterBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(transactionFilterProvider);
    final notifier = ref.read(transactionFilterProvider.notifier);
    final months = ref.watch(availableMonthsProvider);
    final categories = filter.type == null
        ? CategoryCatalog.all
        : CategoryCatalog.forType(filter.type!);
    final selectedCategory =
        filter.categoryId == null ? null : CategoryCatalog.byId(filter.categoryId!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: notifier.setQuery,
          textInputAction: TextInputAction.search,
          decoration: AppTheme.fieldDecoration(
            hintText: 'Search by description',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: filter.query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      notifier.setQuery('');
                    },
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final option in <TransactionType?>[null, ...TransactionType.values])
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(option?.label ?? 'All'),
                    selected: filter.type == option,
                    onSelected: (_) => notifier.setType(option),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: PopupMenuButton<String>(
                  tooltip: 'Filter by category',
                  onSelected: (id) => notifier.setCategory(id.isEmpty ? null : id),
                  itemBuilder: (_) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: '',
                      child: Text('All categories'),
                    ),
                    for (final c in categories)
                      PopupMenuItem<String>(
                        value: c.id,
                        child: Row(
                          children: [
                            Icon(c.icon, color: c.color, size: 20),
                            const SizedBox(width: AppSpacing.sm + 4),
                            Text(c.name),
                          ],
                        ),
                      ),
                  ],
                  child: Chip(
                    avatar: Icon(
                      selectedCategory?.icon ?? Icons.category_outlined,
                      size: 18,
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(selectedCategory?.name ?? 'Category'),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: PopupMenuButton<int>(
                  tooltip: 'Filter by month',
                  onSelected: (index) =>
                      notifier.setMonth(index < 0 ? null : months[index]),
                  itemBuilder: (_) => <PopupMenuEntry<int>>[
                    const PopupMenuItem<int>(value: -1, child: Text('All months')),
                    for (var i = 0; i < months.length; i++)
                      PopupMenuItem<int>(
                        value: i,
                        child: Text(DateFormatter.month(months[i])),
                      ),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.calendar_month_outlined, size: 18),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter.month == null
                              ? 'Month'
                              : DateFormatter.month(filter.month!),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ActionChip(
                  avatar: const Icon(Icons.swap_vert, size: 18),
                  label: Text(
                    filter.sortOrder == SortOrder.newestFirst
                        ? 'Newest first'
                        : 'Oldest first',
                  ),
                  onPressed: notifier.toggleSort,
                ),
              ),
              if (filter.isActive)
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    notifier.reset();
                  },
                  child: const Text('Clear'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
