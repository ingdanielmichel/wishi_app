import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreenIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }
}
