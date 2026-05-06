import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../locale_provider.dart';
import '../../currency_provider.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'widgets/custom_scaffold.dart';
import 'login_screen.dart';

// Screen for viewing/editing user profile, settings, currency, and language preferences
class ProfileSettingsScreen extends StatefulWidget {
  final int userId;
  const ProfileSettingsScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final UserRepository _userRepo = UserRepository();
  final AuthService _auth = AuthService();
  User? _user; // Current user object
  bool _loading = true; // Loading state for data fetch
  final TextEditingController _rateController = TextEditingController(); // Exchange rate input

  @override
  void initState() {
    super.initState();
    _loadUser(); // Load user data when screen initializes
  }

  // Load user data from repository
  Future<void> _loadUser() async {
    setState(() => _loading = true);
    final user = await _userRepo.getUserById(widget.userId);
    
    // Handle missing user (session expired)
    if (user == null) {
      if (mounted) {
        final isArabic = Provider.of<LocaleProvider>(
          context,
          listen: false,
        ).isArabic;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF2A3A4A),
            title: Text(
              isArabic ? 'انتهت الجلسة' : 'Session Expired',
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              isArabic ? 'الرجاء تسجيل الدخول مرة أخرى' : 'Please log in again',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _auth.clearSavedUserId(); // Clear stored user ID
                  if (mounted)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                },
                child: Text(
                  isArabic ? 'حسناً' : 'OK',
                  style: const TextStyle(color: Color(0xFFF5B042)),
                ),
              ),
            ],
          ),
        );
      }
      return;
    }
    
    setState(() {
      _user = user;
      _loading = false;
    });
    _rateController.clear(); // Clear exchange rate field on load
  }

  // Update user's language preference
  Future<void> _updateLanguage(String newLang) async {
    if (_user != null) {
      _user!.language = newLang;
      await _userRepo.updateUser(_user!);
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      await localeProvider.setLocale(Locale(newLang)); // Apply new locale
      await _loadUser(); // Reload user data
    }
  }

  // Log out user and navigate to login screen
  Future<void> _logout() async {
    await _auth.logout(); // Clear authentication session
    if (mounted)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    // Show loading indicator while fetching user data
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E27),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_user == null) return const SizedBox.shrink(); // Fallback if no user

    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'الملف الشخصي والإعدادات' : 'Profile & Settings',
      showBackButton: false,
      hideMenu: false,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFF2A3A4A), // Dark card background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display user's full name (read-only)
                ListTile(
                  title: Text(
                    isArabic ? 'الاسم' : 'Name',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    _user!.fullName,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const Divider(color: Colors.white24),
                // Display user's email (read-only)
                ListTile(
                  title: Text(
                    isArabic ? 'البريد الإلكتروني' : 'Email',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    _user!.email,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const Divider(color: Colors.white24),
                // Currency selection dropdown
                ListTile(
                  title: Text(
                    isArabic ? 'العملة' : 'Currency',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: DropdownButton<String>(
                    dropdownColor: const Color(0xFF2A3A4A),
                    value: currencyProvider.targetCurrency,
                    items: ['EGP', 'USD', 'EUR']
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) async {
                      if (v != null) {
                        currencyProvider.setTargetCurrency(v);
                        _user!.currency = v; // Save currency preference to user
                        await _userRepo.updateUser(_user!);
                        _rateController.clear(); // Clear exchange rate field
                        setState(() {});
                      }
                    },
                  ),
                ),
                // Show exchange rate input field only if target currency is not EGP
                if (currencyProvider.targetCurrency != 'EGP') ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          isArabic
                              ? '1 ${currencyProvider.targetCurrency} = ? جنيه'
                              : '1 ${currencyProvider.targetCurrency} = ? EGP',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _rateController,
                            keyboardType: TextInputType.number, // Numeric keyboard
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: isArabic ? 'مثال: 35' : 'e.g. 35',
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white24,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFF5B042), // Orange highlight
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) {
                              final num = double.tryParse(value);
                              if (num != null && num > 0) {
                                // Update exchange rate in provider when user types
                                currencyProvider.setExchangeRateFromUserInput(
                                  currencyProvider.targetCurrency,
                                  num,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(color: Colors.white24),
                // Language selection dropdown
                ListTile(
                  title: Text(
                    isArabic ? 'اللغة' : 'Language',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: DropdownButton<String>(
                    dropdownColor: const Color(0xFF2A3A4A),
                    value: _user!.language,
                    items: const [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(
                          'English',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ar',
                        child: Text(
                          'العربية',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (v) => _updateLanguage(v!), // Update language when changed
                  ),
                ),
                const SizedBox(height: 30),
                // Logout button (red)
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red button for logout
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isArabic ? 'تسجيل الخروج' : 'Logout',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}