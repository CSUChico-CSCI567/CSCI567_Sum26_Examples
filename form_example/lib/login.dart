import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_example/firebase_options.dart';
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
        _googleUser = _googleUser;
      });
      return userCredential;
    }
  }

  // Future<UserCredential> signInWithGoogle() async {
  //   // Trigger the auth workflow
  //   final GoogleSignIn signIn = GoogleSignIn.instance;
  //   await signIn.initialize()
  //   _googleUser = await signIn.authenticate();
  //   if (kDebugMode) {
  //     print(_googleUser!.displayName);
  //   }
  //   final GoogleSignInClientAuthorization authorization = await _googleUser!
  //       .authorizationClient
  //       .authorizeScopes(scopes);

  //   final GoogleSignInAuthentication? googleAuth =
  //       await _googleUser?.authentication;
  //   final OAuthCredential credential = GoogleAuthProvider.credential(
  //     accessToken: authorization.accessToken,
  //     idToken: googleAuth?.idToken,
  //   );
  //   UserCredential userCredential = await FirebaseAuth.instance
  //       .signInWithCredential(credential);
  //   setState(() {
  //     _googleUser = _googleUser;
  //   });
  //   return userCredential;
  // }

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
        ElevatedButton(
          onPressed: () async {
            await signInWithGoogle();
          },
          child: const Text("Sign in with Google"),
        ),
      );
    } else {
      widgets.add(
        ListTile(
          leading: GoogleUserCircleAvatar(identity: _googleUser!),
          title: Text(_googleUser!.displayName ?? ""),
          subtitle: Text(_googleUser!.email),
        ),
      );
      widgets.add(Text(FirebaseAuth.instance.currentUser?.uid ?? ""));
      widgets.add(
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            await GoogleSignIn.instance.signOut();
            setState(() {
              _googleUser = null;
            });
          },
          child: const Text("Sign Out"),
        ),
      );
    }
    return widgets;
  }
}
