import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:provider/provider.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool isFav = false;
  double rating = 3.5;
  double precio = 1000;
  String nombre = 'Plaza Ñuñoa';
  String imageFile = 'assets/nunoa.jpg';
  String tiempo = 'Precio para 1 hora';

  @override
  Widget build(BuildContext context) {
    dynamic currentTime = DateFormat.jm().format(DateTime.now());
    dynamic nextTime = DateFormat.jm().format(DateTime.now().add(const Duration(hours: 1,)));

    var currentFavIcon = Icons.favorite_outline;
    if (isFav) {
      currentFavIcon = Icons.favorite;
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(nombre)),
            Align(alignment: Alignment.centerLeft, child: Text(tiempo, style: const TextStyle(fontSize: 10))),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => isFav = !isFav),
            icon: Icon(currentFavIcon),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Image(image: AssetImage(imageFile)),
          const SizedBox(height: 10,),
          ListTile(
            title: Column(
              children: [Align(alignment: Alignment.centerLeft, child: Text(nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, ), )),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.star),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: Text('$tiempo:', style: const TextStyle(fontWeight: FontWeight.bold),),),
                Align(alignment: Alignment.centerLeft, child: Text('CL \$$precio',),),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        const Align(alignment: Alignment.centerLeft, child: Text('Desde', style: TextStyle(fontWeight: FontWeight.bold),),),
                        Align(alignment: Alignment.centerLeft, child: Text('$currentTime',),),
                      ],
                    ),
                    const SizedBox(width: 20,),
                    Column(
                      children: [
                        const Align(alignment: Alignment.centerLeft, child: Text('Hasta', style: TextStyle(fontWeight: FontWeight.bold),),),
                        Align(alignment: Alignment.centerLeft, child: Text('$nextTime',),),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5,),
                const Align(alignment: Alignment.centerLeft, child: Text('Características', style: TextStyle(fontWeight: FontWeight.bold),),),
                const Align(alignment: Alignment.centerLeft, child: Text('Casa',),),
              ],
            ),
          ),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }

}

class LocationCard extends StatefulWidget {
  const LocationCard({super.key});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  bool isFav = false;
  double rating = 3.5;
  double estacionamientos = 1;
  double precio = 1000;
  String titulo = 'Plaza Ñuñoa';
  String imageFile = 'assets/nunoa.jpg';
  String tiempo = 'Precio para 1 hora';
  String moneda = 'CLP';
  DateTime fechaHoraDesde = DateTime.now();
  DateTime fechaHoraHasta = DateTime.now().add(const Duration(hours: 1));

  String formatDate(DateTime dateTime, String languageTag) {
    String dia = DateFormat('EEEE', languageTag).format(dateTime);
    String diaMes = '${dateTime.day} ${DateFormat('MMMM', languageTag).format(dateTime).substring(0, 3)}';
    return '${dia.substring(0, 3)}., $diaMes.';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    TextStyle boldStyle = const TextStyle(fontWeight: FontWeight.bold,);
    TextStyle ratingStyle = const TextStyle(color: Colors.black,);

    var stringDisponibilidad = '$estacionamientos estacionamientos disponibles';
    if (estacionamientos == 1) {
      stringDisponibilidad = '1 estacionamiento disponible';
    }

    String stringRangoTiempo;
    if (fechaHoraDesde.day != fechaHoraHasta.day) {
      stringRangoTiempo = '${formatDate(fechaHoraDesde, appState.languageTag)}-${formatDate(fechaHoraHasta, appState.languageTag)}';
    } else {
      stringRangoTiempo = '${DateFormat('jm', appState.languageTag).format(fechaHoraDesde)}-${DateFormat('jm', appState.languageTag).format(fechaHoraHasta)}';
    }

    double totalDuration = fechaHoraHasta.difference(fechaHoraDesde).inMinutes.toDouble() / 60.0;
    String precioCompleto = '\$${precio * totalDuration} $moneda';

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Theme.of(context).primaryColor.withAlpha(30),
        onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const LocationPage()));},
        child: Row(
          children: [
            SizedBox(width: 150,child: Image(image: AssetImage(imageFile)),),
            Expanded(
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Align(alignment: Alignment.topLeft, child: Text(titulo, style: boldStyle,),),
                          Align(alignment: Alignment.topLeft, child: Text(stringDisponibilidad)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {setState(() => isFav = !isFav);},
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Align(alignment: Alignment.bottomLeft, child: Text(stringRangoTiempo,)),
                          Align(alignment: Alignment.bottomLeft, child: Text(precioCompleto, style: boldStyle,)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Align(alignment: Alignment.bottomRight, child: Icon(Icons.star, color: Colors.black, size: 15,)),
                        Align(alignment: Alignment.centerLeft, child: Text('$rating', style: ratingStyle,),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
