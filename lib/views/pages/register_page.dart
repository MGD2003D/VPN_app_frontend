import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vpn/views/widgets/text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

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
              child: Text("Join now!", style: GoogleFonts.kdamThmorPro(fontSize: 64)),
            ),
            CustomTextField(
              controller: fullNameController,
              hintText: "Full name",
              obscureText: false,
            ),
            SizedBox(height: 25),
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
            SizedBox(height: 25),
            CustomTextField(
              controller: passwordConfirmController,
              hintText: "Confirm password",
              obscureText: true,
            ),
            SizedBox(height: 25),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(minimumSize: Size.fromHeight(50)),
              child: Text("Join!", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
