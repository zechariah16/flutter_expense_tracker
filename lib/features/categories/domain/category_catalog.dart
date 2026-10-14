import 'package:flutter/material.dart';

import '../../transactions/domain/transaction_type.dart';
import 'transaction_category.dart';

/// Single source of truth for categories. Widgets look categories up here
/// instead of hardcoding names or icons.
class CategoryCatalog {
  CategoryCatalog._();

  static const List<TransactionCategory> income = [
    TransactionCategory(
      id: 'salary',
      name: 'Salary',
      icon: Icons.payments_outlined,
      color: Color(0xFF1E8E5A),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.laptop_mac_outlined,
      color: Color(0xFF2B8A9E),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'business',
      name: 'Business',
      icon: Icons.storefront_outlined,
      color: Color(0xFF3B7DD8),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'investments',
      name: 'Investments',
      icon: Icons.trending_up,
      color: Color(0xFF6A4FD1),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'gifts',
      name: 'Gifts',
      icon: Icons.card_giftcard_outlined,
      color: Color(0xFFD1569A),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'other_income',
      name: 'Other income',
      icon: Icons.add_circle_outline,
      color: Color(0xFF6B7A90),
      type: TransactionType.income,
    ),
  ];

  static const List<TransactionCategory> expense = [
    TransactionCategory(
      id: 'food',
      name: 'Food',
      icon: Icons.restaurant_outlined,
      color: Color(0xFFE8833A),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_bus_outlined,
      color: Color(0xFF3B7DD8),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'bills',
      name: 'Bills',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFD64545),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFFD1569A),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'health',
      name: 'Health',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF1E8E5A),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.school_outlined,
      color: Color(0xFF6A4FD1),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_outlined,
      color: Color(0xFFB8860B),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'housing',
      name: 'Housing',
      icon: Icons.home_outlined,
      color: Color(0xFF2B8A9E),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'subscriptions',
      name: 'Subscriptions',
      icon: Icons.subscriptions_outlined,
      color: Color(0xFF7B5EA7),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'other_expense',
      name: 'Other expenses',
      icon: Icons.more_horiz,
      color: Color(0xFF6B7A90),
      type: TransactionType.expense,
    ),
  ];

  static const List<TransactionCategory> all = [...income, ...expense];

  static const TransactionCategory _unknown = TransactionCategory(
    id: 'unknown',
    name: 'Uncategorized',
    icon: Icons.help_outline,
    color: Color(0xFF6B7A90),
    type: TransactionType.expense,
  );

  static final Map<String, TransactionCategory> _byId = {
    for (final c in all) c.id: c,
  };

  static List<TransactionCategory> forType(TransactionType type) =>
      type == TransactionType.income ? income : expense;

  /// Falls back to a neutral category so old data never crashes the UI.
  static TransactionCategory byId(String id) => _byId[id] ?? _unknown;
}
