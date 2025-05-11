import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vpn/views/widgets/text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController emailController = TextEditingController();

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
              child: Column(
                children: [
                  Text(
                    "Reset Password",
                    style: GoogleFonts.kdamThmorPro(fontSize: 64),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            CustomTextField(
              controller: emailController,
              hintText: "Email",
              obscureText: true,
            ),
            SizedBox(height: 25),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
              ),
              child: Text("Send email", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
