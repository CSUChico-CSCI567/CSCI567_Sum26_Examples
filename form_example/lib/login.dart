import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_example/firebase_options.dart';
import 'package:form_example/main.dart';
import 'package:form_example/pictures.dart';
import 'package:google_sign_in/google_sign_in.dart';

const List<String> scopes = <String>[];

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GoogleSignInAccount? _googleUser;

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider.addScope(
        'https://www.googleapis.com/auth/contacts.readonly',
      );
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      // String serverClientId = DefaultFirebaseOptions.currentPlatform.appId;
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize();
      _googleUser = await signIn.authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = _googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      setState(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => PhotosPage()),
          (Route<dynamic> route) => false,
        );
      });

      return userCredential;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildBody(),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    List<Widget> widgets = [];
    if (_googleUser == null) {
      widgets.add(
        GestureDetector(
          onTap: () async {
            await signInWithGoogle();
          },
          child: const Image(
            image: AssetImage('assets/googlesignin.png'),
            width: 200,
          ),
        ),
      );
    } else {
      widgets.add(const Text("How'd you get here?"));
    }
    return widgets;
  }
}
