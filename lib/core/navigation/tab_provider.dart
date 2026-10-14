import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the selected bottom-navigation tab.
/// Lives in a provider so any screen (e.g. "See all") can switch tabs.
class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final tabIndexProvider =
    NotifierProvider<TabIndexNotifier, int>(TabIndexNotifier.new);

abstract final class AppTab {
  static const int dashboard = 0;
  static const int transactions = 1;
  static const int statistics = 2;
}
