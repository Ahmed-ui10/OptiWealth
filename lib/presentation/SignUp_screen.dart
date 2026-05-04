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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
  );

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      final isArabic = Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).isArabic;
      return isArabic ? 'البريد الإلكتروني مطلوب' : 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      final isArabic = Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).isArabic;
      return isArabic
          ? 'بريد إلكتروني غير صالح (example@domain.com)'
          : 'Invalid email (example@domain.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      final isArabic = Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).isArabic;
      return isArabic ? 'كلمة المرور مطلوبة' : 'Password is required';
    }
    if (!_passwordRegex.hasMatch(value)) {
      final isArabic = Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).isArabic;
      return isArabic
          ? 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل، حرف واحد، رقم واحد، ورمز خاص واحد'
          : 'Password must be at least 8 chars, one letter, one number, one special character';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _passwordController.text) {
      final isArabic = Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).isArabic;
      return isArabic ? 'كلمة المرور غير متطابقة' : 'Passwords do not match';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final user = await _auth.register(name, email, password);
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      final isArabic = Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).isArabic;
      _showError(
        isArabic ? 'البريد الإلكتروني موجود مسبقاً' : 'Email already exists',
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          isArabic ? 'إنشاء حساب' : 'Sign Up',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFF26349A),
                Color(0xFF0A0E27),
                Color(0xFF26349A),
                Colors.white,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFF26349A),
              Color(0xFF080F42),
              Color(0xFF0A0E27),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Card(
                color: const Color(0xFF2A3A4A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: isArabic ? 'الاسم الكامل' : 'Full Name',
                            labelStyle: const TextStyle(color: Colors.white70),
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
                          validator: (v) => v!.trim().isEmpty
                              ? (isArabic ? 'مطلوب' : 'Required')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                            labelStyle: const TextStyle(color: Colors.white70),
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
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: isArabic ? 'كلمة المرور' : 'Password',
                            labelStyle: const TextStyle(color: Colors.white70),
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
                            errorMaxLines: 2,
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: isArabic
                                ? 'تأكيد كلمة المرور'
                                : 'Confirm Password',
                            labelStyle: const TextStyle(color: Colors.white70),
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
                          validator: _validateConfirm,
                        ),
                        const SizedBox(height: 28),
                        _loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5B042),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isArabic ? 'تسجيل' : 'Register',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isArabic
                                  ? 'لديك حساب بالفعل؟'
                                  : 'Already have an account?',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                              ),
                              child: Text(
                                isArabic ? 'تسجيل الدخول' : 'Login',
                                style: const TextStyle(
                                  color: Color(0xFFF5B042),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
