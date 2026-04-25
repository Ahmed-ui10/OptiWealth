import 'package:flutter/material.dart';
import 'SignUp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isArabic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OptiWealth',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,

        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isArabic = !isArabic;
              });
            },
            child: Text(
              isArabic ? 'EN' : 'AR',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      body:  Container(
        height: double.infinity,
        color: const Color.fromARGB(255, 201, 255, 209),
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
          
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
          
              children: [
          
                SizedBox(height: 40),
          
                Icon(
                  Icons.account_balance,
                  size: 80,
                  color: Colors.green,
                ),
          
                SizedBox(height: 20),
          
                Text(
                  isArabic ? '!مرحباً بعودتك' : 'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
          
                SizedBox(height: 40),
          
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'البريد الإلكتروني' : 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
          
                SizedBox(height: 20),
          
                TextField(
                  obscureText: true,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'كلمة المرور' : 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
          
                Align(
                  alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?'),
                  ),
                ),
          
                SizedBox(height: 10),
          
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
          
                  child: Text(
                    isArabic ? 'تسجيل الدخول' : 'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                
                SizedBox(height: 20),
          
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isArabic ? 'ليس لديك حساب؟' : "Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: Text(isArabic ? 'إنشاء حساب جديد' : 'Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
      
    );
  }
}