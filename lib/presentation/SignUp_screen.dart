import 'package:flutter/material.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
class _SignUpScreenState extends State<SignUpScreen> {
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
      body: Container(
        height: double.infinity,
        color:  Color.fromARGB(255, 201, 255, 209),

        child: SingleChildScrollView(
          padding:  EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

               SizedBox(height: 30),

               Icon(
                Icons.person_add,
                size: 80,
                color: Colors.green,
              ),

               SizedBox(height: 20),

              Text(
                isArabic ? 'إنشاء حساب جديد' : 'Create New Account',
                textAlign: TextAlign.center,
                style:  TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

               SizedBox(height: 30),

              TextField(
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  labelText: isArabic ? 'الاسم بالكامل' : 'Full Name',
                  prefixIcon:  Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

               SizedBox(height: 20),

              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  labelText: isArabic ? 'البريد الإلكتروني' : 'Email Address',
                  prefixIcon:  Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

               SizedBox(height: 20),

              TextField(
                keyboardType: TextInputType.phone,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  labelText: isArabic ? 'رقم الهاتف' : 'Phone Number',
                  prefixIcon:  Icon(Icons.phone),
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
                  prefixIcon:  Icon(Icons.lock),
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
                  labelText: isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
                  prefixIcon:  Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

               SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: Text(
                  isArabic ? 'إنشاء الحساب' : 'Sign Up',
                  style:  TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),

               SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(isArabic ? 'لديك حساب بالفعل؟' : "Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(isArabic ? 'تسجيل الدخول' : 'Login'),
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