import 'package:shared_preferences/shared_preferences.dart';

class CounterStorage {
  final Future<SharedPreferencesWithCache> _prefs =
      SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          // This cache will only accept the key 'counter'.
          allowList: <String>{'counter'},
        ),
      );
  CounterStorage();

  Future<int> readCounter() async {
    final SharedPreferencesWithCache prefs = await _prefs;
    return prefs.getInt("counter") ?? 0;
  }

  Future<void> writeCounter(int counter) async {
    final SharedPreferencesWithCache prefs = await _prefs;
    prefs.setInt('counter', counter);
  }
}
