import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vpn/views/pages/reset_password_page.dart';
import 'package:vpn/views/widgets/text_field.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
        var payload = {
          'username': emailController.text,
          // 'email': emailController.text,
          'password': passwordController.text,
        };

        var response = await http.post(
          Uri.parse('https://dummyjson.com/auth/login'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(payload),
        );

        print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Text(
                "Login",
                style: GoogleFonts.kdamThmorPro(fontSize: 64),
              ),
            ),
            CustomTextField(
              controller: emailController,
              hintText: "Email",
              obscureText: false,
            ),
            SizedBox(height: 25),
            CustomTextField(
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                );
              },
              child: SizedBox(
                width: double.infinity,
                child: Text("Reset password", textAlign: TextAlign.end),
              ),
            ),
            SizedBox(height: 25),
            FilledButton(
              onPressed: () => login(),
              style: FilledButton.styleFrom(minimumSize: Size.fromHeight(50)),
              child: Text("Login", style: TextStyle(fontSize: 20)),
            ),
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
    );
  }
}
