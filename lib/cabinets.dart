import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'components/gradient_container.dart';

class Cabinets extends StatefulWidget {
  const Cabinets({Key? key}) : super(key: key);

  @override
  State<Cabinets> createState() => _CabinetsState();
}

class _CabinetsState extends State<Cabinets> {
  Future<Database> getDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final path = "${prefs.getString("saveDir")}/items.db";
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE full_table(Invent TEXT, "
            "NumKab INTEGER, Count INTEGER);");
      },
    );
    return database;
  }

  Future<List<int>> getCabs() async {
    final database = await getDatabase();
    final list = await database
        .rawQuery("SELECT NumKab FROM full_table GROUP BY NumKab");
    await database.close();
    return list.map((e) => e.values.first! as int).toList();
  }

  Future<void> deleteCab(int cab) async {
    final database = await getDatabase();
    await database.rawQuery(
      "DELETE FROM full_table WHERE NumKab = ?",
      [cab],
    );
  }

  @override
  Widget build(BuildContext context) {
    var future = getCabs();
    return FutureBuilder<List<int>>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        Widget children;
        if (snapshot.connectionState != ConnectionState.done) {
          children = Center(
            child: GradientContainer(
              colors: superGradientColors,
              child: const SizedBox(),
            ),
          );
        } else if (snapshot.hasData) {
          children = GradientContainer(
            colors: superGradientColors,
            child: Scaffold(
              body: ListView.separated(
                itemBuilder: (context, index) => ListTile(
                  trailing: GestureDetector(
                    onTap: () async {
                      await deleteCab(snapshot.data![index]);
                      setState(() {
                        future = getCabs();
                      });
                    },
                    child: const Icon(
                      Icons.delete_forever,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  leading: const SizedBox(),
                  title: Text(
                    textAlign: TextAlign.center,
                    snapshot.data![index].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: snapshot.data!.length,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          children = Center(
            child: Text('Ошибка: ${snapshot.error}'),
          );
        } else {
          children = Center(
            child: GradientContainer(
              colors: superGradientColors,
              child: const SizedBox(),
            ),
          );
        }
        return children;
      },
    );
  }
}
