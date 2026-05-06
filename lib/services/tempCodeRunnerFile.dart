import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/account_repository.dart';
import '../models/account_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Authentication service for user registration, login, and session management
class AuthService {
  final UserRepository _userRepo = UserRepository();
  final AccountRepository _accountRepo = AccountRepository();

  // Hash a password using SHA-256 algorithm
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Save user ID to SharedPreferences for persistent session
  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  // Retrieve saved user ID from SharedPreferences
  Future<int?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Clear saved user ID from SharedPreferences (logout)
  Future<void> clearSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  // Clear all user-related data from SharedPreferences
  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('selected_currency');
    await prefs.remove('exchange_rates');
  }

  // Register a new user
  // Returns User object on success, null if email already exists
  Future<User?> register(String fullName, String email, String password) async {
    // Check if email is already registered
    final existing = await _userRepo.getUserByEmail(email);
    if (existing != null) return null;

    // Hash the password before storing
    final passwordHash = _hashPassword(password);

    // Create user with default settings (EGP currency, Arabic language)
    final user = User(
      fullName: fullName,
      email: email,
      passwordHash: passwordHash,
      currency: 'EGP',
      language: 'ar',
      notificationsEnabled: true,
    );
    
    // Save user to database
    int userId = await _userRepo.createUser(user);
    
    // Create an initial account for the user with zero balance
    await _accountRepo.createAccount(
      Account(userId: userId, balance: 0.0, currency: 'EGP'),
    );
    
    return await _userRepo.getUserById(userId);
  }

  // Login an existing user
  // Returns User object on success, null if credentials are invalid
  Future<User?> login(String email, String password) async {
    final user = await _userRepo.getUserByEmail(email);
    
    // Verify user exists and password matches
    if (user != null && user.passwordHash == _hashPassword(password)) {
      await _saveUserId(user.id!); // Save session
      return user;
    }
    return null;
  }

  // Logout user - clear all stored session data
  Future<void> logout() async {
    await clearAllUserData();
  }
}