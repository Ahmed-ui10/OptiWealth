import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for managing currency conversion and formatting across the app
class CurrencyProvider extends ChangeNotifier {
  static const String _prefKey = 'exchange_rates';

  String _targetCurrency = 'EGP'; // Currently selected currency for display
  double _exchangeRate = 1.0; // Exchange rate from EGP to target currency
  final Map<String, double> _rates = {}; // Store rates: how many EGP = 1 unit of currency

  String get targetCurrency => _targetCurrency;
  double get exchangeRate => _exchangeRate;

  CurrencyProvider() {
    _loadRates();
  }

  // Load saved exchange rates from SharedPreferences
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
    
    // Set default rates if not already saved
    if (!_rates.containsKey('USD'))
      _rates['USD'] = 1.0 / 31.0; // ~ 31 EGP per USD
    if (!_rates.containsKey('EUR'))
      _rates['EUR'] = 1.0 / 35.0; // ~ 35 EGP per EUR
      
    final savedCurrency = prefs.getString('selected_currency') ?? 'EGP';
    _targetCurrency = savedCurrency;
    _exchangeRate = savedCurrency == 'EGP'
        ? 1.0
        : (_rates[savedCurrency] ?? 1.0);
    notifyListeners();
  }

  // Change the target currency for display
  void setTargetCurrency(String currency) {
    if (_targetCurrency == currency) return;
    _targetCurrency = currency;
    _exchangeRate = currency == 'EGP' ? 1.0 : (_rates[currency] ?? 1.0);
    _saveSelectedCurrency();
    notifyListeners();
  }

  // Set custom exchange rate from user input (EGP per unit of foreign currency)
  // eg: if 1 USD = 35 EGP, then egpPerUnit = 35
  void setExchangeRateFromUserInput(String currency, double egpPerUnit) {
    if (currency == 'EGP') return;
    if (egpPerUnit <= 0) return;
    
    final rate = 1.0 / egpPerUnit; // Convert to our internal format (units per 1 EGP)
    _rates[currency] = rate;
    if (_targetCurrency == currency) {
      _exchangeRate = rate;
    }
    _saveRates();
    notifyListeners();
  }

  // Get the user-friendly exchange rate (EGP per unit of currency)
  // This is the inverse of internal rate
  double getUserInputRateForCurrency(String currency) {
    if (currency == 'EGP') return 1.0;
    final rate = _rates[currency] ?? 1.0;
    if (rate == 0) return 0;
    return 1.0 / rate; // Convert internal rate to EGP per unit
  }

  // Convert an amount from EGP to the target currency
  double convert(double amountInEGP) => amountInEGP * _exchangeRate;

  // Format an amount in EGP to target currency with appropriate symbol
  String format(double amountInEGP, bool isArabic) {
    double converted = convert(amountInEGP);
    String symbol;
    if (_targetCurrency == 'EGP') {
      symbol = isArabic ? 'ج.م' : 'E.P'; // EGP symbol with localization
    } else if (_targetCurrency == 'USD') {
      symbol = '\$';
    } else if (_targetCurrency == 'EUR') {
      symbol = '€';
    } else {
      symbol = _targetCurrency;
    }
    return '${converted.toStringAsFixed(2)} $symbol';
  }

  // Save exchange rates to SharedPreferences
  Future<void> _saveRates() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _rates.map((k, v) => MapEntry(k, v as dynamic));
    await prefs.setString(_prefKey, jsonEncode(map));
  }

  // Save selected currency preference
  Future<void> _saveSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', _targetCurrency);
  }
}