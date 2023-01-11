import "package:flutter/material.dart";
import 'package:untitled/components/gradient_container.dart';
import 'package:untitled/utils/database.dart';

class Cabinets extends StatefulWidget {
  const Cabinets({Key? key}) : super(key: key);

  @override
  State<Cabinets> createState() => _CabinetsState();
}

class _CabinetsState extends State<Cabinets> {
  @override
  Widget build(BuildContext context) {
    var future = database.cabinets();
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
                      await database.deleteCabinet(snapshot.data![index]);
                      setState(() {
                        future = database.cabinets();
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
