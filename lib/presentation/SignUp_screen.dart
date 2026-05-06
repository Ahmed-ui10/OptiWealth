import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../locale_provider.dart';
import 'login_screen.dart';

// Signup screen for new user registration
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>(); // Form validation key
  final _nameController = TextEditingController(); // Full name input
  final _emailController = TextEditingController(); // Email input
  final _passwordController = TextEditingController(); // Password input
  final _confirmController = TextEditingController(); // Confirm password input
  final AuthService _auth = AuthService(); // Authentication service
  bool _loading = false; // Loading state for registration

  // Helper method to show error snackbar
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password validation regex pattern (min 8 chars, at least one letter, one number, one special char)
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
  );

  // Validate email format and presence
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

  // Validate password strength
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

  // Validate that password and confirm password match
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

  // Handle user registration
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return; // Validate all fields before proceeding

    setState(() => _loading = true);
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final user = await _auth.register(name, email, password);
    if (user != null) {
      // Registration successful - navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      // Registration failed - email already exists
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
      backgroundColor: const Color(0xFF0A0E27), // Dark blue-black background
      resizeToAvoidBottomInset: true, // Adjust when keyboard appears
      appBar: AppBar(
        title: Text(
          isArabic ? 'إنشاء حساب' : 'Sign Up',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent to show gradient
        elevation: 0, // Remove shadow
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button on signup screen
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
              physics: const BouncingScrollPhysics(), // Smooth scrolling bounce effect
              child: Card(
                color: const Color(0xFF2A3A4A), // Dark card background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Full name input field
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
                                color: Color(0xFFF5B042), // Orange highlight on focus
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v!.trim().isEmpty
                              ? (isArabic ? 'مطلوب' : 'Required')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        // Email input field
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress, // Email keyboard
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
                          validator: _validateEmail, // Custom email validation
                        ),
                        const SizedBox(height: 16),
                        // Password input field (obscured)
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true, // Hide password input
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
                            errorMaxLines: 2, // Allow multi-line error messages
                          ),
                          validator: _validatePassword, // Password strength validation
                        ),
                        const SizedBox(height: 16),
                        // Confirm password input field
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
                          validator: _validateConfirm, // Check if passwords match
                        ),
                        const SizedBox(height: 28),
                        // Register button or loading indicator
                        _loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5B042), // Orange button
                                  minimumSize: const Size(double.infinity, 50), // Full width
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
                        // Link to login screen for existing users
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
                                  color: Color(0xFFF5B042), // Orange link
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