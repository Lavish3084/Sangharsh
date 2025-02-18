import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 0.0;
  static const String _balanceKey = 'wallet_balance';

  double get balance => _balance;

  WalletProvider() {
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getDouble(_balanceKey) ?? 0.0;
    notifyListeners();
  }

  Future<void> addBalance(double amount) async {
    if (amount > 0) {
      _balance += amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_balanceKey, _balance);
      notifyListeners();
    }
  }

  Future<bool> deductBalance(double amount) async {
    if (amount > 0 && _balance >= amount) {
      _balance -= amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_balanceKey, _balance);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool canAfford(double amount) {
    return _balance >= amount;
  }
}
