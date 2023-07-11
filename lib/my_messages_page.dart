import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_filters_page.dart';

class MyMessagesPage extends StatelessWidget {
  const MyMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    List<ColeccionFavoritos> listaColeccionesFavoritos = [];

    Widget messageContainer;

    if (listaColeccionesFavoritos.isEmpty) {
      messageContainer = Container(
        color: Colors.white,
        child: const Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('No tienes mensajes sin leer', style: MyFiltersPage.inputDecoratorLabelStyle,),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Cuando te comuniques con un anfitrión o solicites una reserva, tus mensajes van a aparecer acá',
                  style: TextStyle(color: Colors.grey),),
              ),
            ),
          ],
        ),
      );
    } else {
      List<Widget> listViewChildren = [];

      messageContainer = Container(
        color: Colors.white,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: listViewChildren,
        ),
      );
    }

    return messageContainer;
  }

}
