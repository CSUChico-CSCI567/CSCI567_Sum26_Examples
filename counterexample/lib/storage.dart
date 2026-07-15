import 'package:shared_preferences/shared_preferences.dart';

class CounterStorage {
  SharedPreferences? prefs;
  CounterStorage();

  Future<int> readCounter() async {
    prefs ??= await SharedPreferences.getInstance();
    return prefs!.getInt("counter") ?? 0;
  }

  Future<void> writeCounter(int counter) async {
    prefs ??= await SharedPreferences.getInstance();
    prefs!.setInt('counter', counter);
  }
}
