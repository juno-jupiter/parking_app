import 'package:flutter/material.dart';
import 'package:parking_app/my_reservation_page.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_filters_page.dart';

class MyScheduledPage extends StatelessWidget {
  const MyScheduledPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    int selectedIndex = appState.scheduledPageSelectedIndex;

    List<List<BoletaReserva>> todasLasReservas = [[], [], [], []];
    List<BoletaReserva> listaBoletasReserva = [];
    if (appState.perfilUsuario != null) {
      todasLasReservas = appState.perfilUsuario!.listadoBoletasReserva;
      listaBoletasReserva = todasLasReservas[selectedIndex];
    }
    Widget scheduledContainer;

    List<bool> toggleButtonIsSelected = List<bool>.filled(4, false);
    toggleButtonIsSelected[selectedIndex] = true;

    TextStyle toggleSelectedStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16);
    TextStyle greyStyle = const TextStyle(color: Colors.grey,);

    Widget navigationBar = SizedBox(
      width: double.infinity,
      child: Center(
        child: ToggleButtons(
          onPressed: (int index) {
            appState.selectScheduledNavigationIndex(index);
          },
          fillColor: Colors.white10,
          borderColor: Colors.white10,
          selectedBorderColor: Colors.white10,
          isSelected: toggleButtonIsSelected,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Activas', style: toggleButtonIsSelected[0] ? toggleSelectedStyle : greyStyle,),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
                child: Text('Completadas', style: toggleButtonIsSelected[1] ? toggleSelectedStyle : greyStyle,),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Pendientes', style: toggleButtonIsSelected[2] ? toggleSelectedStyle : greyStyle,),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Canceladas', style: toggleButtonIsSelected[3] ? toggleSelectedStyle : greyStyle,),
            ),
          ],
        ),
      ),
    );

    if (todasLasReservas.isEmpty) {
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
      for (var reserva in listaBoletasReserva.reversed) {
        listViewChildren.add(ScheduledCard(boletaReserva: reserva,));
      }

      double totalHeight = MediaQuery.of(context).size.height;
      scheduledContainer = Container(
        height: totalHeight,
        color: Colors.white,
        child: Column(
          children: [
            navigationBar,
            const Divider(),
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              children: listViewChildren,
            ),
          ],
        ),
      );
    }
    return scheduledContainer;
  }

}

class ScheduledCard extends StatelessWidget {
  static const TextStyle boldStyle = TextStyle(fontWeight: FontWeight.bold,);
  final BoletaReserva boletaReserva;

  const ScheduledCard({super.key, required this.boletaReserva,});

  Card getScheduledCard(BuildContext context, MyAppState appState) {
    boletaReserva.recalculateTotalCost();
    Widget? cardImage;
    String tituloCarta = '';
    String stringRangoTiempo = '';
    if (boletaReserva.location != null) {
      cardImage = const Image(image: AssetImage("assets/nunoa.jpg"));
      tituloCarta = boletaReserva.location!.tituloLocation;
      if (boletaReserva.listaRangoFecha.isNotEmpty) {
        stringRangoTiempo = getStringFromDates(boletaReserva.listaRangoFecha.first.fechaHoraDesde, boletaReserva.listaRangoFecha.last.fechaHoraHasta, appState.languageTag);
      }
    } else {
      cardImage = const SizedBox(width: 200, height: 200, child: null,);
    }

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Theme.of(context).primaryColor.withAlpha(30),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> DetalleBoletaPage(boletaReserva)));
        },
        child: Row(
          children: [
            ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 100),
                child: Container(
                    color: Colors.grey,
                    width: 150, height: double.infinity,
                    child: FittedBox(clipBehavior: Clip.hardEdge, fit: BoxFit.fill, child: cardImage,)
                )
            ),
            Expanded(
              child: ListTile(
                title: Text(tituloCarta),
                titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold,),
                subtitle: Text(stringRangoTiempo),
                trailing: const Icon(Icons.navigate_next),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    return getScheduledCard(context, appState);
  }
}