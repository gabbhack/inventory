import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vibration/vibration.dart';

import 'components/gradient_container.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key, required this.cabinet});
  final int cabinet;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  HashSet<int> items = HashSet();
  late Database database;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      final path = prefs.getString("saveDir");
      openDatabase(
        path!,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS full_table(Invent TEXT, Name TEXT,NumKab INTEGER, Count INTEGER);");
        },
      ).then((value) => database = value);
    });
  }

  @override
  void dispose() {
    database.close().then((value) => super.dispose());
  }

  Future<void> onFailedScan() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Ой'),
        content: const Text('Не удалось отсканировать код'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> onCaptureCode(String data) async {
    final splitted = data.split("_");
    final cabinet = int.tryParse(splitted[0])!;
    final item = int.tryParse(splitted[1])!;
    if (cabinet != widget.cabinet) {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Ой'),
          content: Text('Предмет из кабинета $cabinet'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ПЕРЕНЕСТИ'),
            ),
          ],
        ),
      );
    } else if (items.contains(item)) {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Ой'),
          content: const Text('Предмет уже отсканирован'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      items.add(item);
      Vibration.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      colors: superGradientColors,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 8,
              child: MobileScanner(
                onDetect: (barcode, _) async {
                  if (barcode.rawValue == null) {
                    await onFailedScan();
                  } else {
                    final String code = barcode.rawValue!;
                    await onCaptureCode(code);
                  }
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                child: const Text(
                  'ЗАКОНЧИТЬ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
