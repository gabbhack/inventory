import 'dart:io';

import 'package:csv/csv.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseSingleton {
  late Database database;
  late String savePath;
  late String deviceName;

  DatabaseSingleton._private();

  Future<void> exportCSV() async {
    final rawResult = await database.transaction(
      (txn) => txn.rawQuery("SELECT Invent, NumKab, Count from full_table"),
    );
    final List<List<String>> lists = rawResult
        .map(
          (Map<String, dynamic> e) =>
              e.values.map((dynamic e) => e!.toString()).toList(),
        )
        .toList();
    lists.insert(0, ["invent", "num_cab", "count"]);
    final csv = const ListToCsvConverter().convert(lists);
    File("$savePath/$deviceName.csv").writeAsString(csv);
  }

  Future<void> init() async {
    final databasePath =
        await getDatabasesPath().then((value) => "$value/database.sqlite");
    deviceName =
        await DeviceInfoPlugin().androidInfo.then((value) => value.model);
    savePath =
        await getApplicationDocumentsDirectory().then((value) => value.path);
    database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) =>
          db.execute("CREATE TABLE full_table(Invent TEXT, "
              "NumKab INTEGER, Count INTEGER);"),
    );
  }

  Future<void> close() {
    return database.close();
  }

  Future<void> insertItem(int count, int cabinet, String item) async {
    await database.transaction(
      (txn) => txn.rawQuery(
        "INSERT INTO full_table VALUES (?,?,?)",
        [item, cabinet, count],
      ),
    );
    await exportCSV();
  }

  Future<bool> checkItem(int cabinet, String item) {
    return database
        .transaction(
          (txn) => txn.rawQuery(
            "SELECT COUNT(*) FROM full_table WHERE Invent = ? AND NumKab = ?",
            [item, cabinet],
          ),
        )
        .then((value) => Sqflite.firstIntValue(value))
        .then((value) => value != 0);
  }

  Future<void> deleteItem(int cabinet, String item) async {
    await database.transaction(
      (txn) => txn.rawQuery(
        "DELETE FROM full_table WHERE Invent = ? AND NumKab = ?",
        [item, cabinet],
      ),
    );
    await exportCSV();
  }

  Future<List<int>> cabinets() async {
    return database
        .transaction(
          (txn) =>
              txn.rawQuery("SELECT NumKab FROM full_table GROUP BY NumKab"),
        )
        .then((value) => value.map((e) => e.values.first! as int).toList());
  }

  Future<void> deleteCabinet(int cab) async {
    await database.transaction(
      (txn) => txn.rawQuery(
        "DELETE FROM full_table WHERE NumKab = ?",
        [cab],
      ),
    );
    await exportCSV();
  }
}

final database = DatabaseSingleton._private();
