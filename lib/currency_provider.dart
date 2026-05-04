import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  static const String _prefKey = 'exchange_rates';

  String _targetCurrency = 'EGP';
  double _exchangeRate =
      1.0; 
  final Map<String, double> _rates = {}; 

  String get targetCurrency => _targetCurrency;
  double get exchangeRate => _exchangeRate;

  CurrencyProvider() {
    _loadRates();
  }

  Future<void> _loadRates() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefKey);
    if (json != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(json);
        map.forEach((key, value) {
          _rates[key] = (value as num).toDouble();
        });
      } catch (e) {}
    }
    if (!_rates.containsKey('USD'))
      _rates['USD'] = 1.0 / 31.0; 
    if (!_rates.containsKey('EUR'))
      _rates['EUR'] = 1.0 / 35.0; 
    final savedCurrency = prefs.getString('selected_currency') ?? 'EGP';
    _targetCurrency = savedCurrency;
    _exchangeRate = savedCurrency == 'EGP'
        ? 1.0
        : (_rates[savedCurrency] ?? 1.0);
    notifyListeners();
  }

  void setTargetCurrency(String currency) {
    if (_targetCurrency == currency) return;
    _targetCurrency = currency;
    _exchangeRate = currency == 'EGP' ? 1.0 : (_rates[currency] ?? 1.0);
    _saveSelectedCurrency();
    notifyListeners();
  }

  void setExchangeRateFromUserInput(String currency, double egpPerUnit) {
    if (currency == 'EGP') return;
    if (egpPerUnit <= 0) return;
    final rate =
        1.0 / egpPerUnit; 
    _rates[currency] = rate;
    if (_targetCurrency == currency) {
      _exchangeRate = rate;
    }
    _saveRates();
    notifyListeners();
  }

  double getUserInputRateForCurrency(String currency) {
    if (currency == 'EGP') return 1.0;
    final rate = _rates[currency] ?? 1.0;
    if (rate == 0) return 0;
    return 1.0 / rate;
  }

  double convert(double amountInEGP) => amountInEGP * _exchangeRate;

  String format(double amountInEGP, bool isArabic) {
    double converted = convert(amountInEGP);
    String symbol;
    if (_targetCurrency == 'EGP') {
      symbol = isArabic ? 'ج.م' : 'E.P';
    } else if (_targetCurrency == 'USD') {
      symbol = '\$';
    } else if (_targetCurrency == 'EUR') {
      symbol = '€';
    } else {
      symbol = _targetCurrency;
    }
    return '${converted.toStringAsFixed(2)} $symbol';
  }

  Future<void> _saveRates() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _rates.map((k, v) => MapEntry(k, v as dynamic));
    await prefs.setString(_prefKey, jsonEncode(map));
  }

  Future<void> _saveSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', _targetCurrency);
  }
}
