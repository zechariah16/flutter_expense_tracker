import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/tab_provider.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/statistics/presentation/screens/statistics_screen.dart';
import 'features/transactions/presentation/screens/transaction_form_screen.dart';
import 'features/transactions/presentation/screens/transactions_screen.dart';

/// Bottom navigation + the prominent Add button.
/// IndexedStack keeps each tab's state (scroll position, filters) alive.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          DashboardScreen(),
          TransactionsScreen(),
          StatisticsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openTransactionForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => ref.read(tabIndexProvider.notifier).select(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}
