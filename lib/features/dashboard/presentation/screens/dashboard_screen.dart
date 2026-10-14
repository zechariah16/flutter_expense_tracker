import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/tab_provider.dart';
import '../../../../core/widgets/month_selector.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../statistics/presentation/providers/statistics_providers.dart';
import '../../../statistics/presentation/widgets/category_spending_list.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/transactions_gate.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/recent_transactions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: TransactionsGate(builder: (_) => const _DashboardBody()),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(allTimeBalanceProvider);
    final month = ref.watch(selectedMonthProvider);
    final summary = ref.watch(monthSummaryProvider);
    final spending = ref.watch(categorySpendingProvider);
    final recent = ref.watch(recentTransactionsProvider);
    final tabs = ref.read(tabIndexProvider.notifier);

    return ListView(
      // Extra bottom padding keeps the last item clear of the Add button.
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 96),
      children: [
        BalanceCard(balanceInMinorUnits: balance),
        const SizedBox(height: AppSpacing.md),
        MonthSelector(
          month: month,
          onChanged: ref.read(selectedMonthProvider.notifier).select,
        ),
        MonthlySummaryCard(summary: summary),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'Spending by category',
          trailing: TextButton(
            onPressed: () => tabs.select(AppTab.statistics),
            child: const Text('Details'),
          ),
          child: CategorySpendingList(items: spending, limit: 4),
        ),
        const SizedBox(height: AppSpacing.md),
        RecentTransactions(
          transactions: recent,
          onSeeAll: () => tabs.select(AppTab.transactions),
        ),
      ],
    );
  }
}
