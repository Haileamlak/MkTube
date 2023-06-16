import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingModel with ChangeNotifier {
  bool darkMode = false;
  String language = "Amharic";
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  SettingModel() {
    initConnectivity();
  }

  void handleDarkMode({required bool dark}) async {
    darkMode = dark;
    notifyListeners();
    final getPrefs = await SharedPreferences.getInstance();
    getPrefs.setBool("dark", dark);
  }

  void handleLanguage({required String lang}) {
    language = lang;
    notifyListeners();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    final getPrefs = await SharedPreferences.getInstance();
    darkMode = getPrefs.getBool("dark") ?? false;

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    connectionStatus = result;
    notifyListeners();
  }
}
