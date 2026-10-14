/// App-wide constants. Keeping them here avoids "magic values" in widgets.
class AppConstants {
  AppConstants._();

  static const String appName = 'Expense Tracker';
  static const String databaseName = 'expense_tracker.db';
  static const String currencySymbol = '₦';
  static const int recentTransactionsLimit = 5;
}

/// Spacing scale used across the UI (multiples of 4).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppRadius {
  AppRadius._();

  static const double card = 16;
  static const double field = 12;
}
