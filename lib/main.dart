import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.systemLocale = await findSystemLocale();
  await deleteDatabase('parking.db');
  final Database database = await openDatabase(
    join(await getDatabasesPath(), 'parking.db'), version: 1,
      onCreate: (database, version) async {
        await Location.createTable(database);
        await Estacionamiento.createTable(database);
        await Perfil.createTable(database);
        await Anfitrion.createTable(database);
        await IdiomaPersona.createTable(database);
        await ColeccionFavoritos.createTable(database);
        await Favorito.createTable(database);
        await RangoFecha.createTable(database);
        await BoletaReserva.createTable(database);
      }
  );
  await Perfil(1, 'CLP', '', -1).insert(database);
  await Location(
    1, -33.45260687351389, -70.59197637461642, 'Inacap Ñuñoa (Ex - Pérez Rosales)',
    4.5, 'Brown Norte', '290', 'Ñuñoa', 'edificio', 1, 'Universidad', 0, 1, 0,
  ).insert(database);
  await Location(
    2, -33.45586944527495, -70.59375821933992, 'Plaza Ñuñoa',
    4.5, 'Manuel de Salas', '71', 'Ñuñoa', 'edificio', 2, 'Plaza frente a la municipalidad', 1, 1, 1,
  ).insert(database);
  await Estacionamiento(1, 1, 'Estacionamiento subterráneo', 1000.0, 4.5, '', 'auto').insert(database);
  await Estacionamiento(2, 1, 'Estacionamiento exterior', 700.0, 3.3, '', 'auto').insert(database);
  await Estacionamiento(3, 2, 'Estacionamiento #1', 800.0, 4.2, '', 'auto').insert(database);
  await Estacionamiento(4, 2, 'Estacionamiento #2', 600.0, 3.85, '', 'moto').insert(database);
  await Estacionamiento(5, 3, 'Estacionamiento #3', 600.0, 3.65, '', 'moto').insert(database);
  await Anfitrion(1, 3.2, "Inacap Ñuñoa", 'Universidad').insert(database);
  await Anfitrion(2, 4.6, "Municipalidad Ñuñoa", 'Cuenta oficial').insert(database);
  runApp(MyApp(database: database,));
}

class MyApp extends StatelessWidget {
  final Database database;
  const MyApp({required this.database, super.key});

  @override
  Widget build(BuildContext context) {
    MyAppState appState = MyAppState(database: database,);
    MyHomePage myHomePage = MyHomePage(database);
    return ChangeNotifierProvider(
      create: (context) => appState,
      child: MaterialApp(
        title: 'Parking App',
        theme: ThemeData(primarySwatch: Colors.blue,),
        home: myHomePage,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale('es', ''),
        ],
      ),
    );
  }
}
