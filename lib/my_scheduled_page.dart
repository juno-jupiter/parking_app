import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_filters_page.dart';

class MyScheduledPage extends StatelessWidget {
  const MyScheduledPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    List<ColeccionFavoritos> listaColeccionesFavoritos = [];

    Widget scheduledContainer;

    if (listaColeccionesFavoritos.isEmpty) {
      scheduledContainer = Container(
        color: Colors.white,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('No tienes ningún estacionamiento reservado', style: MyFiltersPage.inputDecoratorLabelStyle,),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {appState.selectNavigationIndex(NavigationPageIndex.main);},
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Empieza a buscar', style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  children: [
                    Text('¿No encuentras tu reserva aquí? ',),
                    Text('Visita el Centro de ayuda', style: MyFiltersPage.underlinedStyle,),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      List<Widget> listViewChildren = [];

      scheduledContainer = Container(
        color: Colors.white,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: listViewChildren,
        ),
      );
    }

    return scheduledContainer;
  }

}
