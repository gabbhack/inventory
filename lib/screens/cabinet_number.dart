import 'package:flutter/material.dart';
import 'package:untitled/components/appbar.dart';
import 'package:untitled/components/gradient_container.dart';
import 'package:untitled/screens/cabinets.dart';
import 'package:untitled/screens/scan.dart';

class CabinetNumberPage extends StatefulWidget {
  const CabinetNumberPage({super.key});

  @override
  State<CabinetNumberPage> createState() => _CabinetNumberState();
}

class _CabinetNumberState extends State<CabinetNumberPage> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  void onCabinetNumberSubmit(int value) {
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.clear();

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ScannerPage(
          cabinet: value,
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      colors: superGradientColors,
      child: Scaffold(
        appBar: const CustomAppBar(
          onPressed: Cabinets(),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ВВЕДИТЕ НОМЕР КАБИНЕТА',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 330,
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
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      onCabinetNumberSubmit(int.tryParse(_controller.text)!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  child: const Text(
                    'ОК',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
