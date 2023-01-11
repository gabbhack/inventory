import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/screens/home.dart';
import 'package:untitled/utils/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  final prefs = await SharedPreferences.getInstance();
  String? selectedDirectory = prefs.getString("saveDir");
  while (selectedDirectory == null) {
    selectedDirectory = await FilePicker.platform.getDirectoryPath();
  }
  await prefs.setString("saveDir", selectedDirectory);
  await database.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ИИнвентаризация',
      theme: ThemeData(
        colorSchemeSeed: Colors.grey,
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
