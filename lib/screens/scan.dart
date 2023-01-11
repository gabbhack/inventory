import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:untitled/utils/database.dart';
import 'package:vibration/vibration.dart';

import '../components/gradient_container.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key, required this.cabinet});

  final int cabinet;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool isDialogOpen = false;

  Future<int?> getItemsCount(BuildContext context) async {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async {
          return false;
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
                  isDialogOpen = false;
                  Navigator.pop(context, int.tryParse(_controller.text));
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onItemsAmountSubmit(int count, int cabinet, String item) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.clear();
    isDialogOpen = false;
    await database.insertItem(count, cabinet, item);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> onFailedScan() async {
    isDialogOpen = true;
    await showDialog<void>(
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
    final itemInDb = await database.checkItem(item);
    isDialogOpen = true;
    if (itemInDb) {
      await showDialog<void>(
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
              TextButton(
                onPressed: () {
                  database.deleteItem(item).then(
                    (value) {
                      Navigator.pop(context);
                      isDialogOpen = false;
                    },
                  );
                },
                child: const Text('Удалить'),
              )
            ],
          ),
        ),
      );
    } else if (cabinet != widget.cabinet) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            title: const Text('Ой'),
            content: Text('Предмет из кабинета $cabinet'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  getItemsCount(context).then(
                    (value) => onItemsAmountSubmit(value!, widget.cabinet, item)
                        .then((value) {
                      Navigator.pop(context);
                      isDialogOpen = false;
                    }),
                  );
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
    } else {
      Vibration.vibrate();
      final count = await getItemsCount(context);
      await onItemsAmountSubmit(count!, cabinet, item);
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
                    isDialogOpen = true;
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
