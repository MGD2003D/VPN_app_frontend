import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vpn/auth/secure_storage_service.dart';
import 'package:vpn/config.dart';
import 'package:vpn/views/pages/login_page.dart';
import 'package:vpn/views/pages/register_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _token;
  String _text = "";
  bool _isLoading = true;

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
        setState(() {
          _text = response.body;
        });
      }
    }

    setState(() {
      _token = token;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_token != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_text),
            SizedBox(height: 25),
            ElevatedButton(onPressed: () async {
              await SecureStorageService().deleteToken();
              setState(() {
                _token = null;
              });
            }, child: Text("Logout")),
          ],
        ),
      );
    }

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
