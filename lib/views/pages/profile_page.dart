import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vpn/auth/secure_storage_service.dart';
import 'package:vpn/config.dart';
import 'package:vpn/views/pages/login_page.dart';
import 'package:vpn/views/pages/register_page.dart';
import 'package:vpn/views/widgets/register_form.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _token;
  bool _isLoading = true;
  String _username = "";
  String _email = "";

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await SecureStorageService().getToken();

    if (token != null) {
      var response = await http.get(
        Uri.http(Config.apiHost, Config.currentUserInfoUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        setState(() {
          _username = jsonBody["username"] ?? "empty";
          _email = jsonBody["email"];
        });
      } else {
        _logout();
      }
    }

    setState(() {
      _token = token;
      _isLoading = false;
    });
  }

  void _updateUser(String email, username, password) async {
    final payload = {"email": email, "username": username};

    if (password.isNotEmpty) {
      payload["password"] = password;
    }

    if (_token == null) {
      return;
    }

    var response = await http.patch(
      Uri.http(Config.apiHost, Config.userUpdateUrl),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Authorization": "Bearer ${_token}",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Account updated!")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error")));
    }
  }

  void _logout() async {
    await SecureStorageService().deleteToken();
    setState(() {
      _token = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_token != null) {
      return Column(
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 25),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _username,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _email,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                      ),
                      child: Icon(Icons.logout, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: RegisterForm(
              isEditing: true,
              initialEmail: _email,
              initialUsername: _username,
              submitCallback: _updateUser,
            ),
          ),
        ],
      );
    } //

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            style: FilledButton.styleFrom(minimumSize: Size.fromHeight(50)),
            child: Text("Login"),
          ),
          SizedBox(height: 25),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: Size.fromHeight(50),
            ),
            child: Text("Register"),
          ),
        ],
      ),
    );
  }
}
