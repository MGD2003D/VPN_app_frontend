import 'package:flutter/material.dart';
import 'package:vpn/views/pages/login_page.dart';
import 'package:vpn/views/pages/register_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
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
