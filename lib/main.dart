import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'my_app_state.dart';
import 'my_home_page.dart';


Future<void> main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  Intl.systemLocale = await findSystemLocale();
  // await deleteDatabase('parking.db');
  final Database database = await openDatabase(
    join(await getDatabasesPath(), 'parking.db'), version: 1,
      onCreate: (database, version) async {
        // await database.execute('drop table locations');
        // await database.execute('drop table estacionamientos');
        await Location.createTable(database);
        await Estacionamiento.createTable(database);
      }
  );
  await Location(
    1, -33.45260687351389, -70.59197637461642, 'Inacap Ñuñoa (Ex - Pérez Rosales)',
    4.5, 'Brown Norte', '290', 'Ñuñoa', 'Edificio', 1, 'Universidad',
  ).insert(database);
  await Estacionamiento(1, 1, 'Estacionamiento #1', 1000.0, 4.5, '').insert(database);
  await Estacionamiento(2, 1, 'Estacionamiento #2 moto', 600.0, 3.85, '').insert(database);
  runApp(MyApp(database: database,));
}

class MyApp extends StatelessWidget {
  final Database database;
  const MyApp({required this.database, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(database: database),
      child: MaterialApp(
        title: 'Parking App',
        theme: ThemeData(primarySwatch: Colors.blue,),
        home: MyHomePage(database),
      ),
    );
  }
}
