import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../locale_provider.dart';
import '../../currency_provider.dart';
import '../../repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'widgets/custom_scaffold.dart';
import 'login_screen.dart';

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
  User? _user;
  bool _loading = true;
  final TextEditingController _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    final user = await _userRepo.getUserById(widget.userId);
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
                  await _auth.clearSavedUserId();
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
    _rateController.clear();
  }

  Future<void> _updateLanguage(String newLang) async {
    if (_user != null) {
      _user!.language = newLang;
      await _userRepo.updateUser(_user!);
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      await localeProvider.setLocale(Locale(newLang));
      await _loadUser();
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
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

    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E27),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_user == null) return const SizedBox.shrink();

    return CustomScaffold(
      userId: widget.userId,
      title: isArabic ? 'الملف الشخصي والإعدادات' : 'Profile & Settings',
      showBackButton: false,
      hideMenu: false,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFF2A3A4A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                // Currency selection
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
                        _user!.currency = v;
                        await _userRepo.updateUser(_user!);
                        _rateController.clear(); 
                        setState(() {});
                      }
                    },
                  ),
                ),
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
                            keyboardType: TextInputType.number,
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
                                  color: Color(0xFFF5B042),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) {
                              final num = double.tryParse(value);
                              if (num != null && num > 0) {
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
                    onChanged: (v) => _updateLanguage(v!),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
