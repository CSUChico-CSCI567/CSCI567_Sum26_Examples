import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

final String tableCount = 'tableCount';
final String columnId = '_id';
final String columnCount = 'count';

class CountObject {
  late int id;
  late int count;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{columnCount: count, columnId: id};
    return map;
  }

  CountObject();

  CountObject.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    count = map[columnCount];
  }
}

class CounterStorage {
  late Database _db;
  final Completer<void> _dataCompleter = Completer<void>();

  void initDB() async {
    await open("counter.db");
    _dataCompleter.complete(); // Signals that the variable is ready
  }

  CounterStorage() {
    initDB();
  }

  Future open(String path) async {
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
create table $tableCount ( 
  $columnId integer primary key autoincrement, 
  $columnCount integer not null)
''');
      },
    );
  }

  Future<CountObject> insert(CountObject co) async {
    co.id = await _db.insert(tableCount, co.toMap());
    return co;
  }

  Future<CountObject> getCount(int id) async {
    List<Map> maps = await _db.query(
      tableCount,
      columns: [columnId, columnCount],
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return CountObject.fromMap(maps.first);
    }
    CountObject co = CountObject();
    co.count = 0;
    co.id = id;
    co = await insert(co);
    return co;
  }

  Future<int> update(CountObject co) async {
    return await _db.update(
      tableCount,
      co.toMap(),
      where: '$columnId = ?',
      whereArgs: [co.id],
    );
  }

  Future close() async => _db.close();

  Future<int> readCounter() async {
    try {
      await _dataCompleter.future; // Code pauses here until defined
      CountObject co = await getCount(1);
      return co.count;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return 0;
    }
  }

  Future<void> writeCounter(int counter) async {
    try {
      await _dataCompleter.future; // Code pauses here until defined
      CountObject co = CountObject();
      co.count = counter;
      co.id = 1;
      await update(co);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
