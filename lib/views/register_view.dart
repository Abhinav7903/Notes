import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/Dialog/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  bool passwordVisible = true;
  final _focusNode = FocusNode();

  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    passwordVisible = true;
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _email,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                  labelText: "Email",
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide:
                          const BorderSide(width: 3, color: Colors.blueGrey)),
                  //visible after click in text field
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide:
                          const BorderSide(width: 3, color: Colors.green)),
                  hintText: 'Enter your email',
                  alignLabelWithHint: false,
                  filled: true,
                ),
                focusNode: _focusNode,
              ),
              const SizedBox(height: 20), // Add some space here
              TextField(
                controller: _password,
                obscureText: passwordVisible,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide:
                          const BorderSide(width: 3, color: Colors.blueGrey)),
                  //visible after click in text field
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide:
                          const BorderSide(width: 3, color: Colors.green)),
                  hintText: "Password",
                  labelText: "Password",
                  helperText: "Password must contain special character",
                  helperStyle: const TextStyle(color: Colors.green),
                  suffixIcon: IconButton(
                    icon: Icon(passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(
                        () {
                          passwordVisible = !passwordVisible;
                        },
                      );
                    },
                  ),
                  alignLabelWithHint: false,
                  filled: true,
                ),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(
                width: 110,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    try {
                      await AuthService.firebase()
                          .createUser(email: email, password: password);
                      await AuthService.firebase().sendEmailVerification();
                      Navigator.of(context).pushNamed(verifyEmail);
                    } on WeakPasswordAuthException {
                      await showErrorDialog(context, "Weak password");
                    } on EmailAlreadyInUseAuthException {
                      await showErrorDialog(context, "Email Already Exist");
                      log('Email is already in use');
                    } on InvalidEmailAuthException {
                      await showErrorDialog(context, "Invalid Mail");
                    } on GenericAuthException {
                      await showErrorDialog(context, "Failed to register");
                    } on FirebaseAuthException catch (e) {
                      await showErrorDialog(context, 'Error:${e.code}');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      padding: EdgeInsetsDirectional.all(10)),
                  child: const Text("Register"),
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  },
                  child: const Text("Already Registered? Login here"))
            ],
          ),
        ),
      ),
    );
  }
}
