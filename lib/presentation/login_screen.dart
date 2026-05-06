import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../locale_provider.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';

// Login screen for user authentication
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Form validation key
  final _emailController = TextEditingController(); // Email input field
  final _passwordController = TextEditingController(); // Password input field
  final AuthService _auth = AuthService(); // Authentication service
  bool _loading = false; // Loading state for login operation

  // Handle login action
  Future<void> _login() async {
    // Validate form before attempting login
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    
    // Attempt to login with provided credentials
    final user = await _auth.login(
      _emailController.text,
      _passwordController.text,
    );
    
    if (user != null) {
      // Login successful - navigate to dashboard with user ID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(userId: user.id!)),
      );
    } else {
      // Login failed - show error message
      final isArabic = Provider.of<LocaleProvider>(
        context,
        listen: false,
      ).isArabic;
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
    final isArabic = Provider.of<LocaleProvider>(context).isArabic;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27), // Dark blue-black background
      resizeToAvoidBottomInset: true, // Adjust when keyboard appears
      appBar: AppBar(
        title: Text(
          isArabic ? 'تسجيل الدخول' : 'Login',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent to show gradient
        elevation: 0, // Remove shadow
        centerTitle: true, // Center the title
        automaticallyImplyLeading: false, // No back button on login screen
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
                        // Email input field
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
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
                                color: Color(0xFFF5B042), // Orange highlight on focus
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v!.contains('@')
                              ? null
                              : (isArabic ? 'بريد غير صالح' : 'Invalid email'), // Email format validation
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
                          ),
                          validator: (v) => v!.length >= 6
                              ? null
                              : (isArabic ? 'قصيرة جداً' : 'Too short'), // Minimum 6 characters
                        ),
                        const SizedBox(height: 24),
                        // Login button or loading indicator
                        _loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5B042), // Orange button
                                  minimumSize: const Size(double.infinity, 50), // Full width
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isArabic ? 'دخول' : 'Login',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 20),
                        // Signup link for new users
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(
                                isArabic
                                    ? 'ليس لديك حساب؟'
                                    : "Don't have an account?",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to signup screen (replace current)
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  isArabic ? 'إنشاء حساب' : 'Create Account',
                                  style: const TextStyle(
                                    color: Color(0xFFF5B042), // Orange link
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
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