import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/services/auth/firebase_auth_provider.dart';
import 'package:notes/views/forgot.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/notes/create_update_note_view.dart';
import 'package:notes/views/notes/notes_views.dart';
import 'package:notes/views/register_view.dart';
import 'package:notes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const CircularProgressIndicator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.purple,
          iconTheme: IconThemeData(color: Colors.white),
          toolbarTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.grey[900],
          iconTheme: const IconThemeData(color: Colors.white),
          toolbarTextStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          titleTextStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        brightness: Brightness.dark, // set brightness to dark
        scaffoldBackgroundColor: Colors.grey[900],
      ),

      home:  BlocProvider<AuthBloc>(
          create:(context)=>AuthBloc(FirebaseAuthProvider()) ,
          child: const Homepage()),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmail: (context) => const VerifyEmailView(),
        forgotRoute: (context) => const ForgotPassword(),
        createUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    );
  }
}

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc,AuthState>(

        builder: (context,state){
      if (state is AuthStateLoggedIn) {
        return const NotesView();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPassword();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });

  }
}
