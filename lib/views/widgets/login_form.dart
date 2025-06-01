import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vpn/auth/secure_storage_service.dart';
import 'package:vpn/config.dart';
import 'package:vpn/views/pages/reset_password_page.dart';
import 'package:vpn/views/pages/widget_tree.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      var payload = {
        "email": email,
        "password": password,
      };

      var response = await http.post(
        Uri.http(Config.apiHost, Config.loginUrl),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)["token"];
        await SecureStorageService().saveToken(token);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WidgetTree()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email";
              } else if (!_isValidEmail(value)) {
                return "Enter a valid email";
              }
              return null;
            },
          ),
          SizedBox(height: 25),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: "Password",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your password";
              } else if (value.length < 8) {
                return "Password must be at least 8 characters";
              }
              return null;
            },
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
            onPressed: _login,
            style: FilledButton.styleFrom(minimumSize: Size.fromHeight(50)),
            child: Text("Login", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
