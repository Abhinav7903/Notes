import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';

import '../constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  "We've sent you an email verification.Please visit the inbox😃\n"),
            ),
            TextButton(
                onPressed: () async {
                  await AuthService.firebase().sendEmailVerification();
                },
                child: const Text("Send Verification Email")),
            TextButton(
                onPressed: () async {
                  await AuthService.firebase().logOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(registerRoute, (route) => false);
                },
                child: const Text("Restart"))
          ],
        ),
      ),
    );
  }
}
