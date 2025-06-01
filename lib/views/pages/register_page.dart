import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:vpn/config.dart';
import 'package:vpn/views/pages/login_page.dart';
import 'package:vpn/views/widgets/register_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  void _register(String email, username, password) async {
    final payload = {
      "email": email,
      "username": username,
      "password": password,
    };

    var response = await http.post(
      Uri.http(Config.apiHost, Config.registerUrl),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created! Please log in.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error")));
    }
  }
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
                  "Join now!",
                  style: GoogleFonts.kdamThmorPro(fontSize: 64),
                ),
              ),
              RegisterForm(
                submitCallback: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
