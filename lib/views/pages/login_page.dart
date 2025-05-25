import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vpn/views/widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  "Login",
                  style: GoogleFonts.kdamThmorPro(fontSize: 64),
                ),
              ),
              LoginForm(),
              SizedBox(height: 25),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Text("Or continue with"),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, size: 50),
                  SizedBox(width: 25),
                  Icon(Icons.android, size: 50),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
