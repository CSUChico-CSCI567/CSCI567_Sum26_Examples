import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_example/login.dart';
import 'package:form_example/photoform.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PhotosPage extends StatefulWidget {
  const PhotosPage({super.key});

  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photos"),
        actions: [
          Tooltip(
            message: "Logout",
            child: IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                GoogleSignIn.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PhotoForm()),
          );
        },
        tooltip: "Add Photo",
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget getBody() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instanceFor(
                app: Firebase.app(),
                databaseId: 'summer26',
              )
              .collection("photos")
              .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.hasData) {
          return ListView(
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data['title']),
                    Text(data['description']),
                    Image.network(data['imageURL'], height: 300),
                  ],
                ),
              );
            }).toList(),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
