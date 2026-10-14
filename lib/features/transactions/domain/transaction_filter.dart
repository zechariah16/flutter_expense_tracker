import '../../../core/utils/month.dart';
import 'transaction.dart';
import 'transaction_type.dart';

enum SortOrder { newestFirst, oldestFirst }

/// Immutable description of the History screen's search/filter/sort state.
class TransactionFilter {
  const TransactionFilter({
    this.query = '',
    this.type,
    this.categoryId,
    this.month,
    this.sortOrder = SortOrder.newestFirst,
  });

  final String query;
  final TransactionType? type;
  final String? categoryId;
  final Month? month;
  final SortOrder sortOrder;

  /// True when something narrows the list (sorting does not count).
  bool get isActive =>
      query.trim().isNotEmpty || type != null || categoryId != null || month != null;

  TransactionFilter copyWith({
    String? query,
    TransactionType? type,
    bool clearType = false,
    String? categoryId,
    bool clearCategory = false,
    Month? month,
    bool clearMonth = false,
    SortOrder? sortOrder,
  }) {
    return TransactionFilter(
      query: query ?? this.query,
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      month: clearMonth ? null : (month ?? this.month),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// All conditions combine with AND. Ties on date are broken by creation time.
  List<MoneyTransaction> apply(Iterable<MoneyTransaction> transactions) {
    final q = query.trim().toLowerCase();
    final result = transactions.where((t) {
      if (q.isNotEmpty && !t.title.toLowerCase().contains(q)) return false;
      if (type != null && t.type != type) return false;
      if (categoryId != null && t.categoryId != categoryId) return false;
      if (month != null && !month!.contains(t.date)) return false;
      return true;
    }).toList();

    result.sort((a, b) {
      var c = a.date.compareTo(b.date);
      if (c == 0) c = a.createdAt.compareTo(b.createdAt);
      return sortOrder == SortOrder.newestFirst ? -c : c;
    });
    return result;
  }
}
