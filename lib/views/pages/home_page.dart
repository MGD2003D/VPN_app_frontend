import 'package:flutter/material.dart';
import 'package:vpn/auth/secure_storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _text = "";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(_text),
          FilledButton(
            onPressed: () async {
              final token = await SecureStorageService().getToken();
              setState(() {
                _text = token ?? "No token";
              });
            },
            child: Text("Click"),
          ),
        ],
      ),
    );
  }
}
