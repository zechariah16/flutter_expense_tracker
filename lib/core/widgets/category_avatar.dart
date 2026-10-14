import 'package:flutter/material.dart';

import '../../features/categories/domain/transaction_category.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.category, this.size = 40});

  final TransactionCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: category.color.withValues(alpha: 0.14),
      child: Icon(category.icon, color: category.color, size: size * 0.5),
    );
  }
}
