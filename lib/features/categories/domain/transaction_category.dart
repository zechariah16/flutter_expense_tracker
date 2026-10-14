import 'package:flutter/material.dart';

import '../../transactions/domain/transaction_type.dart';

class TransactionCategory {
  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  /// Stable key stored in the database. Never change an id once released.
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;
}
