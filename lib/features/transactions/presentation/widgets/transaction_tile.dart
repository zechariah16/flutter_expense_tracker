import 'package:flutter/material.dart';

import '../../../../core/money/money.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/category_avatar.dart';
import '../../../categories/domain/category_catalog.dart';
import '../../domain/transaction.dart';
import '../screens/transaction_details_screen.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final MoneyTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final category = CategoryCatalog.byId(transaction.categoryId);
    final color = transaction.isIncome
        ? AppColors.income(context)
        : AppColors.expense(context);

    return Card(
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TransactionDetailsScreen(transactionId: transaction.id),
          ),
        ),
        leading: CategoryAvatar(category: category),
        title: Text(
          transaction.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${category.name} • ${DateFormatter.day(transaction.date)}'),
        trailing: Text(
          Money.formatSigned(
            transaction.amountInMinorUnits,
            isIncome: transaction.isIncome,
          ),
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
