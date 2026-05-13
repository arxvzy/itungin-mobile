import 'package:flutter/foundation.dart';

class AppNavProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _previousIndex = 0;

  int get currentIndex => _currentIndex;
  int get previousIndex => _previousIndex;

  void setIndex(int index) {
    if (index == _currentIndex) return;
    _previousIndex = _currentIndex;
    _currentIndex = index;
    notifyListeners();
  }

  void reset() {
    _previousIndex = 0;
    _currentIndex = 0;
    notifyListeners();
  }
}
