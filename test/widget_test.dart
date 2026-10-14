import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_data.dart';

void main() {
  Widget buildApp() => ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(FakeTransactionRepository()),
        ],
        child: const ExpenseTrackerApp(),
      );

  testWidgets('dashboard shows the balance card', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Total balance'), findsOneWidget);
    expect(find.text('₦0.00'), findsWidgets);
  });

  testWidgets('saving an empty form shows validation errors', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final save = find.text('Save transaction');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid amount (up to 2 decimals)'), findsOneWidget);
    expect(find.text('Enter a description'), findsOneWidget);
    expect(find.text('Select a category'), findsOneWidget);
  });
}
