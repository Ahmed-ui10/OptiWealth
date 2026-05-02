import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../locale_provider.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final user = await _auth.login(
      _emailController.text,
      _passwordController.text,
    );
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(userId: user.id!)),
      );
    } else {
      final isArabic =
          Provider.of<LocaleProvider>(
            context,
            listen: false,
          ).locale.languageCode ==
          'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'بيانات غير صحيحة' : 'Invalid credentials'),
        ),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'تسجيل الدخول' : 'Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                ),
                validator: (v) => v!.contains('@')
                    ? null
                    : (isArabic ? 'بريد غير صالح' : 'Invalid email'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'كلمة المرور' : 'Password',
                ),
                obscureText: true,
                validator: (v) => v!.length >= 6
                    ? null
                    : (isArabic ? 'قصيرة جداً' : 'Too short'),
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text(isArabic ? 'دخول' : 'Login'),
                    ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupScreen()),
                ),
                child: Text(isArabic ? 'إنشاء حساب' : 'Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
