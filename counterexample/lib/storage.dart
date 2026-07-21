import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CounterStorage {
  CounterStorage();

  Future<int> readCounter() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'summer26',
      );
      DocumentSnapshot ds = await firestore
          .collection("test")
          .doc("count")
          .get();
      if (ds.exists && ds.data() != null) {
        Map<String, dynamic> data = ds.data() as Map<String, dynamic>;
        if (data.containsKey('count')) {
          return data['count'];
        }
      }
      await writeCounter(0);
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return 0;
    }
  }

  Future<void> writeCounter(int counter) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'summer26',
      );
      await firestore.collection('test').doc('count').set({'count': counter});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
