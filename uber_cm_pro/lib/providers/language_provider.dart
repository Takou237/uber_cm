import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('fr'); // Français par défaut

  Locale get currentLocale => _currentLocale;

  void changeLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    notifyListeners(); // Rafraîchit l'UI
  }
}