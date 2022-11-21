import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/cabinet_number.dart';

import 'components/gradient_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      colors: superGradientColors,
      child: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              Permission.camera.request();
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
