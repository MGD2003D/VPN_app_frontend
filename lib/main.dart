import 'package:flutter/material.dart';
import 'package:vpn/config.dart';
import 'package:vpn/views/pages/widget_tree.dart';
import 'package:vpn/views/pages/home_page.dart';
import 'package:vpn/views/pages/user_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF3CE054),
          brightness: Brightness.dark,
          ),
      ),
      debugShowCheckedModeBanner: false,
      home: WidgetTree(),
      // home: UserHome(),
    );
  }
}
