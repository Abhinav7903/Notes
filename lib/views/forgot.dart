import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/Dialog/error_dialog.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late final TextEditingController _email;
  final _focusNode = FocusNode();

  @override
  void initState() {
    _email = TextEditingController();
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text("Forgot"),centerTitle: true,backgroundColor: Colors.deepPurpleAccent,),
      body: Column(
        children: [
          SizedBox(height: 20),
          TextField(
            controller: _email,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(width: 3, color: Colors.green)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(width: 3, color: Colors.green)),
              hintText: 'Enter your email',
              labelText: "Email",
            ),
            focusNode: _focusNode,
          ),
          SizedBox(
            width: 110,
            child: ElevatedButton(
                onPressed: () async {
                  final email = _email.text;
                  try {
                    // final user = FirebaseAuth.instance
                    //     .sendPasswordResetEmail(email: email);
                    await AuthService.firebase().sendPasswordReset(toEmail: email);
                  }
                  on UserNotFoundAuthException {
                    await showErrorDialog(context, "User not Found");
                  }
                  on GenericAuthException {
                    await showErrorDialog(context, 'Authentication Error');
                  }
                },
                style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    padding: const EdgeInsetsDirectional.all(10)),
                child: const Text("Click here!")),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text("Go back to Login")),
        ],
      ),
    );
  }
}
