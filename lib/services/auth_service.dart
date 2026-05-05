import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/account_repository.dart';
import '../models/account_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final UserRepository _userRepo = UserRepository();
  final AccountRepository _accountRepo = AccountRepository();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  Future<int?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> clearSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('selected_currency');
    await prefs.remove('exchange_rates');
  }

  Future<User?> register(String fullName, String email, String password) async {
    final existing = await _userRepo.getUserByEmail(email);
    if (existing != null) return null;

    final passwordHash = _hashPassword(password);

    final user = User(
      fullName: fullName,
      email: email,
      passwordHash: passwordHash,
      currency: 'EGP',
      language: 'ar',
      notificationsEnabled: true,
    );
    int userId = await _userRepo.createUser(user);
    await _accountRepo.createAccount(
      Account(userId: userId, balance: 0.0, currency: 'EGP'),
    );
    return await _userRepo.getUserById(userId);
  }

  Future<User?> login(String email, String password) async {
    final user = await _userRepo.getUserByEmail(email);
    if (user != null && user.passwordHash == _hashPassword(password)) {
      await _saveUserId(user.id!);
      return user;
    }
    return null;
  }

  Future<void> logout() async {
    await clearAllUserData();
  }
}