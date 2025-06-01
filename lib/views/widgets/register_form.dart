import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  final String? initialFullName;
  final String? initialEmail;
  final String? initialUsername;
  final void Function(String email, String username, String password)? submitCallback;
  final bool isEditing;

  const RegisterForm({
    super.key,
    this.initialFullName,
    this.initialEmail,
    this.initialUsername,
    this.submitCallback,
    this.isEditing = false,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? "");
    _usernameController = TextEditingController(
      text: widget.initialUsername ?? "",
    );
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(email);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final username = _usernameController.text;
      final password = _passwordController.text;

      if (widget.submitCallback != null) {
        widget.submitCallback!(email, username, password);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
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
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter your username";
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
              if (!widget.isEditing && (value == null || value.isEmpty)) {
                return "Please enter a password";
              } else if (value != null && value.isNotEmpty && value.length < 8) {
                return "Password must be at least 8 characters";
              }
              return null;
            },
          ),
          SizedBox(height: 25),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (!widget.isEditing && (value == null || value.isEmpty)) {
                return "Please confirm your password";
              } else if (value != _passwordController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
          SizedBox(height: 25),
          FilledButton(
            onPressed: _submitForm,
            style: FilledButton.styleFrom(minimumSize: Size.fromHeight(50)),
            child: Text(
              widget.isEditing ? "Save" : "Join!",
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }
}
