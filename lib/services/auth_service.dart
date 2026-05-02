import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/account_repository.dart';
import '../models/account_model.dart';

class AuthService {
  final UserRepository _userRepo = UserRepository();
  final AccountRepository _accountRepo = AccountRepository();

  Future<User?> register(String fullName, String email, String password) async {
    final existing = await _userRepo.getUserByEmail(email);
    if (existing != null) return null;
    final user = User(
      fullName: fullName,
      email: email,
      passwordHash: password,
      currency: 'EGP',     
      language: 'ar',      
      notificationsEnabled: true,
    );
    int userId = await _userRepo.createUser(user);
    await _accountRepo.createAccount(Account(
      userId: userId,
      balance: 0.0,
      currency: 'EGP',
    ));
    return await _userRepo.getUserById(userId);
  }

  Future<User?> login(String email, String password) async {
    final user = await _userRepo.getUserByEmail(email);
    if (user != null && user.passwordHash == password) return user;
    return null;
  }
}