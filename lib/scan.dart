import 'dart:collection';

import 'package:flutter/material.dart';
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
  late TextEditingController _controller;
  HashSet<String> items = HashSet();
  late Database database;
  late SharedPreferences prefs;
  final _formKey = GlobalKey<FormState>();
  bool isDialogOpen = false;

  void onItemsAmountSubmit(int value) {
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.clear();
    isDialogOpen = false;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      final path = "${prefs.getString("saveDir")}/items.db";
      openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE IF NOT EXISTS full_table(Invent TEXT, Name TEXT, "
              "NumKab INTEGER, Count INTEGER);");
        },
      ).then((value) {
        return database = value;
      });
    });
  }

  @override
  void dispose() {
    database.close().then((value) {
      _controller.dispose();
      super.dispose();
    });
  }

  Future<void> onFailedScan() async {
    isDialogOpen = true;
    await showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async {
          isDialogOpen = false;
          return true;
        },
        child: AlertDialog(
          title: const Text('Ой'),
          content: const Text('Не удалось отсканировать код'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                isDialogOpen = false;
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onCaptureCode(String data) async {
    final splitted = data.split("_");
    final cabinet = int.tryParse(splitted[0])!;
    final item = splitted[1];
    if (cabinet != widget.cabinet) {
      isDialogOpen = true;
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => WillPopScope(
          onWillPop: () async {
            isDialogOpen = false;
            return true;
          },
          child: AlertDialog(
            title: const Text('Ой'),
            content: Text('Предмет из кабинета $cabinet'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  isDialogOpen = false;
                },
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  isDialogOpen = false;
                },
                child: const Text('ПЕРЕНЕСТИ'),
              ),
            ],
          ),
        ),
      );
    } else if (items.contains(item)) {
      isDialogOpen = true;
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => WillPopScope(
          onWillPop: () async {
            isDialogOpen = false;
            return true;
          },
          child: AlertDialog(
            title: const Text('Ой'),
            content: const Text('Предмет уже отсканирован'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  isDialogOpen = false;
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
    } else {
      items.add(item);
      Vibration.vibrate();
      isDialogOpen = true;
      await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WillPopScope(
          onWillPop: () async {
            isDialogOpen = false;
            return true;
          },
          child: AlertDialog(
            title: const Text('Уточните'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Введите количество предметов инвентаря'),
                const SizedBox(height: 50),
                Form(
                  onWillPop: () async => false,
                  key: _formKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Введите число';
                      } else {
                        return null;
                      }
                    },
                    controller: _controller,
                    autofocus: true,
                    cursorColor: Colors.white,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                    decoration: const InputDecoration(
                      fillColor: Colors.grey,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    onItemsAmountSubmit(int.tryParse(_controller.text)!);
                    isDialogOpen = false;
                    Navigator.pop(context);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
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
                allowDuplicates: true,
                onDetect: (barcode, _) async {
                  if (!isDialogOpen) {
                    if (barcode.rawValue == null) {
                      await onFailedScan();
                    } else {
                      final String code = barcode.rawValue!;
                      await onCaptureCode(code);
                    }
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
