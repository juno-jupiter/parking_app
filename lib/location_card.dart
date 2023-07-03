import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/my_app_state.dart';

class LocationPage extends StatefulWidget {
  final Location location;
  const LocationPage(this.location, { super.key });
  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    widget.location.recalculateTotalCost(appState.getTotalDuration());

    bool isFav = appState.favLocations.contains(widget.location.id);
    Image? cardImage;
    if (widget.location.id > 0) {cardImage = const Image(image: AssetImage("assets/nunoa.jpg"));}
    int estacionamientos = widget.location.estacionamientosLista.length;
    String stringDisponibilidad = '$estacionamientos estacionamientos disponibles';
    if (estacionamientos == 1) {stringDisponibilidad = '1 estacionamiento disponible';}

    double precioTotal = widget.location.precioTotal;
    String precioCompleto = (widget.location.estacionamientosLista.length > 1) ? 'Desde \$$precioTotal ${appState.moneda}' : '\$$precioTotal ${appState.moneda}';
    String stringRangoTiempo = getTimeRangeString(appState);
    String titulo = widget.location.nombre;
    double rating = widget.location.rating;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(titulo)),
            Align(alignment: Alignment.centerLeft, child: Text(stringRangoTiempo, style: const TextStyle(fontSize: 10))),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {appState.toggleFavoriteLocation(widget.location);},
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
          )
        ],
      ),
      body: Column(
        children: [
          ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            children: [
              SizedBox(width: double.infinity, height: 300, child: FittedBox(fit: BoxFit.fill, child: cardImage,)),
              const SizedBox(height: 10,),
            ],
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatefulWidget {
  final Location location;
  const LocationCard(this.location, { super.key });
  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  Card getLocationCard(BuildContext context, MyAppState appState) {
    TextStyle boldStyle = const TextStyle(fontWeight: FontWeight.bold,);
    TextStyle ratingStyle = const TextStyle(color: Colors.black,);
    widget.location.recalculateTotalCost(appState.getTotalDuration());

    bool isFav = appState.favLocations.contains(widget.location.id);
    Image? cardImage;
    if (widget.location.id > 0) {cardImage = const Image(image: AssetImage("assets/nunoa.jpg"));}
    int estacionamientos = widget.location.estacionamientosLista.length;
    String stringDisponibilidad = '$estacionamientos estacionamientos disponibles';
    if (estacionamientos == 1) {stringDisponibilidad = '1 estacionamiento disponible';}

    double precioTotal = widget.location.precioTotal;
    String precioCompleto = (widget.location.estacionamientosLista.length > 1) ? 'Desde \$$precioTotal ${appState.moneda}' : '\$$precioTotal ${appState.moneda}';
    String stringRangoTiempo = getTimeRangeString(appState);
    String titulo = widget.location.nombre;
    double rating = widget.location.rating;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Theme.of(context).primaryColor.withAlpha(30),
        onTap: () {
          appState.toggleLocationPage(widget.location);
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> LocationPage(widget.location,)));
          },
        child: Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
                child: SizedBox(width: 150, height: double.infinity, child: FittedBox(clipBehavior: Clip.hardEdge, fit: BoxFit.fill, child: cardImage,))
            ),
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
                      onPressed: () {appState.toggleFavoriteLocation(widget.location);},
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    return getLocationCard(context, appState);
  }
}
