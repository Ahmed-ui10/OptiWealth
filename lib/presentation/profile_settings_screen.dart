import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../locale_provider.dart';
import '../../repositories/user_repository.dart';
import '../../models/user_model.dart';
import 'login_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final int userId;
  const ProfileSettingsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final UserRepository _userRepo = UserRepository();
  User? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _userRepo.getUserById(widget.userId);
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _updateLanguage(String newLang) async {
    if (_user != null) {
      _user!.language = newLang;
      await _userRepo.updateUser(_user!);
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      localeProvider.setLocale(Locale(newLang));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    if (_loading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'الملف الشخصي والإعدادات' : 'Profile & Settings')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(title: Text(isArabic ? 'الاسم' : 'Name'), trailing: Text(_user!.fullName)),
            ListTile(title: Text(isArabic ? 'البريد الإلكتروني' : 'Email'), trailing: Text(_user!.email)),
            ListTile(
              title: Text(isArabic ? 'العملة' : 'Currency'),
              trailing: DropdownButton(
                value: _user!.currency,
                items: ['USD', 'EGP', 'EUR'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) async {
                  _user!.currency = v!;
                  await _userRepo.updateUser(_user!);
                  setState(() {});
                },
              ),
            ),
            ListTile(
              title: Text(isArabic ? 'اللغة' : 'Language'),
              trailing: DropdownButton(
                value: _user!.language,
                items: [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (v) => _updateLanguage(v!),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())),
              child: Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}