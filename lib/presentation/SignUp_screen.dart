import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../locale_provider.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).locale.languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'إنشاء حساب' : 'Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: isArabic ? 'الاسم الكامل' : 'Full Name'),
                validator: (v) => v!.isNotEmpty ? null : (isArabic ? 'مطلوب' : 'Required'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: isArabic ? 'البريد الإلكتروني' : 'Email'),
                validator: (v) => v!.contains('@') ? null : (isArabic ? 'بريد غير صالح' : 'Invalid email'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: isArabic ? 'كلمة المرور' : 'Password'),
                obscureText: true,
                validator: (v) => v!.length >= 6 ? null : (isArabic ? 'أقل من 6 حروف' : 'Min 6 chars'),
              ),
              TextFormField(
                controller: _confirmController,
                decoration: InputDecoration(labelText: isArabic ? 'تأكيد كلمة المرور' : 'Confirm'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_passwordController.text != _confirmController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'كلمة المرور غير متطابقة' : 'Passwords mismatch')));
                          return;
                        }
                        setState(() => _loading = true);
                        final user = await _auth.register(_nameController.text, _emailController.text, _passwordController.text);
                        if (user != null) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isArabic ? 'البريد موجود مسبقاً' : 'Email already exists')));
                        }
                        setState(() => _loading = false);
                      },
                      child: Text(isArabic ? 'تسجيل' : 'Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}