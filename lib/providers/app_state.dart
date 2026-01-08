import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  int _counter = 0;
  bool _isLoading = false;
  String _message = '';

  int get counter => _counter;
  bool get isLoading => _isLoading;
  String get message => _message;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  void reset() {
    _counter = 0;
    _isLoading = false;
    _message = '';
    notifyListeners();
  }
}
