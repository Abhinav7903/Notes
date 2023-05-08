import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';

import '../constants/routes.dart';
import '../utilities/Dialog/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  bool passwordVisible = true;
  final _focusNode = FocusNode();
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _focusNode.requestFocus();
    super.initState();
    passwordVisible = true;
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
        title: const Text("Login"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(children: [
              TextField(
                controller: _email,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.emailAddress,
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
                  labelText: "Email",
                  hintText: 'Enter your email',
                  alignLabelWithHint: false,
                  filled: true,
                ),
                focusNode: _focusNode,
              ),
              const SizedBox(
                height: 20,
              ),
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
                width: 100,
                child: ElevatedButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    if (email.isEmpty || password.isEmpty) {
                      await showErrorDialog(
                          context, "Email and password are required");
                      return;
                    }
                    try {
                      // context.read<AuthBloc>().add(AuthEventLogIn
                      //   (email, password));
                      await AuthService.firebase().logIn(email: email, password: password);
                      Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                    } on UserNotFoundAuthException {
                      await showErrorDialog(context, "User not Found");
                    } on WrongPasswordAuthException {
                      await showErrorDialog(context, "Wrong Password");
                      log("Wrong password");
                    } on GenericAuthException {
                      await showErrorDialog(context, 'Authentication Error');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      padding: const EdgeInsetsDirectional.all(10)),
                  child: const Text("Login"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(registerRoute, (route) => false);
                },
                child: const Text("Not register yet? Register here"),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(forgotRoute);
                  },
                  child: const Text("Forgot password?")),
            ]),
          )),
    );
  }
}
