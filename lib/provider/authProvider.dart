import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _userId = "";

  String get userId => _userId;

  void setUserId(String userId) {
    _userId = userId;
    print('Setting userId to: $_userId');
    notifyListeners();
  }
}

class empolyeeProvider with ChangeNotifier {
  String _empolyeeName = '';

  String get empolyeeName => _empolyeeName;
  void setempolyeeName(String name) {
    _empolyeeName = name;
    notifyListeners();
  }
}
