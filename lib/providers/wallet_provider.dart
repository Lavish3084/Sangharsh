import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 0.0;
  bool _isLoading = false;

  WalletProvider() {
    loadSavedBalance();
  }

  double get balance => _balance;
  bool get isLoading => _isLoading;

  Future<void> loadSavedBalance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _balance = prefs.getDouble('wallet_balance') ?? 0.0;
    } catch (e) {
      print('Error loading wallet balance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBalance(double amount) async {
    if (amount <= 0) return;

    _isLoading = true;
    notifyListeners();

    try {
      _balance += amount;
      await _saveBalance();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deductBalance(double amount) async {
    if (amount <= 0 || _balance < amount) return false;

    _isLoading = true;
    notifyListeners();

    try {
      _balance -= amount;
      await _saveBalance();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('wallet_balance', _balance);
  }

  bool canAfford(double amount) {
    return _balance >= amount;
  }

  bool hasSufficientBalance(double amount) {
    return canAfford(amount);
  }
}
