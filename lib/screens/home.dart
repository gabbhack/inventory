import 'package:flutter/material.dart';
import 'package:untitled/components/appbar.dart';
import 'package:untitled/components/gradient_container.dart';
import 'package:untitled/screens/cabinet_number.dart';
import 'package:untitled/screens/cabinets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      colors: superGradientColors,
      child: Scaffold(
        appBar: const CustomAppBar(
          onPressed: Cabinets(),
        ),
        body: Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const CabinetNumberPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            child: const Text(
              'НАЧАТЬ ИНВЕНТАРИЗАЦИЮ',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
