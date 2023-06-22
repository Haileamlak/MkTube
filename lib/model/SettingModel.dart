import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingModel with ChangeNotifier {
  bool darkMode = false;
  String _language = "am";
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  SettingModel() {
    initConnectivity();
  }

  //
  void setDarkMode({required bool dark}) async {
    darkMode = dark;
    notifyListeners();
    final getPrefs = await SharedPreferences.getInstance();
    getPrefs.setBool("dark", dark);
  }

  void setLanguage({required String lang}) {
    _language = lang;
    notifyListeners();
  }

  String get language {
    switch (_language) {
      case "en":
        return "English";
      case "am":
        return "Amharic";
      case "gez":
        return "Geez";
      default:
        return "";
    }
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
  //

  String getLocalized({required String key}) {
    if (_db.containsKey(_language)) {
      return _db[_language]?[key] ?? "-";
    }
    return _db["en"]?[key] ?? "-";
  }

  static final Map<String, Map<String, String>> _db = {
    "en": {
      "hello": "Hello!",
      "setting": "Settings",
      "home": "Home",
      "tv": "Tv",
      "library": "Library",
      "downloaded": "Downloaded",
    },
    "am": {
      "hello": "ሄሎ!",
      "setting": "ማስተካከያዎች",
      "home": "ቤት",
      "tv": "ቴቪ",
      "library": "ስብስብ",
      "downloaded": "የወረዱ",
    },
    "gez": {
      "hello": "Hola!",
      "setting": "",
      "home": "ማኅደር",
      "tv": "ቴቪ",
      "library": "ስብስብ",
      "downloaded": "Downloaded",
    }
  };
}
