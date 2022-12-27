import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/cabinet_number.dart';
import 'package:file_picker/file_picker.dart';

import 'components/gradient_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> getPermissions() async {
    await Permission.camera.request();
    final prefs = await SharedPreferences.getInstance();
    String? selectedDirectory = prefs.getString("saveDir");
    while (selectedDirectory == null) {
      selectedDirectory = await FilePicker.platform.getDirectoryPath();
    }
    await prefs.setString("saveDir", selectedDirectory);
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      colors: superGradientColors,
      child: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              getPermissions();
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
