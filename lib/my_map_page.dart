import 'package:flutter/material.dart';
import 'package:parking_app/my_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'my_app_state.dart';
import 'location_card.dart';

class MyMapPage extends StatefulWidget {
  final List<Location> locationList;
  const MyMapPage(this.locationList, {super.key});

  @override
  State<MyMapPage> createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  final double dragTriggerRange = 150.0;
  double initialDrag = 0.0;
  double currentDrag = 0.0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    Widget mapView = FlutterMap(
      options: MapOptions(
        center: const LatLng(-33.45260687351389, -70.59197637461642),
        zoom: 17.0,
        maxZoom: 18.0,
        minZoom: 12.0,
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      ),
      nonRotatedChildren: [
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MyMarkerLayer(widget.locationList),
      ],
    );

    String estacionamientosDisponibles = (widget.locationList.length == 1) ?
    '${widget.locationList.length} estacionamiento disponible' : '${widget.locationList.length} estacionamientos disponibles';

    Widget openListView = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (DragStartDetails details) {initialDrag = details.globalPosition.dy;},
      onVerticalDragUpdate: (DragUpdateDetails details) {
        currentDrag = details.globalPosition.dy;
        if (currentDrag < (initialDrag - dragTriggerRange)) {appState.toggleListView();}
      },
      child: Card(child: SizedBox(
        height: 60,
        child: Center(child: Column(
          children: [
            const Icon(Icons.drag_handle),
            Text(estacionamientosDisponibles, style: const TextStyle(fontWeight: FontWeight.bold,),),
          ],
        ),),
      ),),
    );

    Widget searchBar = Column(
        children: [
          const SizedBox(height: 36,),
          const MySearchBar(),
          const Expanded(child:Center(child:null),),
          openListView,
        ]
    );
    if (appState.selectedLocation != null) {
      searchBar = Column(
          children: [
            const SizedBox(height: 36,),
            const MySearchBar(),
            const Expanded(child:Center(child:null),),
            Stack(children: [
              LocationCard(appState.selectedLocation!),
              Opacity(opacity: 0.5, child: IconButton(onPressed: (){
                appState.toggleLocationMarker(appState.selectedLocation);
              }, icon: const Icon(Icons.cancel)))
            ]),
            openListView,
          ]
      );
    }
    return Stack(children: [mapView, searchBar],);
  }
}

class MyMarkerLayer extends StatelessWidget {
  final List<Location> locationList;
  const MyMarkerLayer(this.locationList, {super.key});

  Marker getMarker(BuildContext context, MyAppState appState, Location location) {
    String markerString = '';
    bool isSelected = false;

    Color markerColor = Colors.white;
    Color textColor = Colors.black;
    double latitud = 0.0;
    double longitud = 0.0;

    latitud = location.lat;
    longitud = location.lng;
    double precioTotal = location.precioTotal;
    markerString = '\$$precioTotal';

    isSelected = appState.selectedLocation?.id == location.id;
    if (isSelected) {
      markerColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
    }
    markerString = '\$$precioTotal ${appState.moneda}';

    return Marker(
        point: LatLng(latitud, longitud),
        width: 120,
        height: 80,
        builder: (context) => Stack(
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(backgroundColor: markerColor,),
                onPressed: () => {appState.toggleLocationMarker(location)},
                child: Text(markerString, style: TextStyle(color: textColor),),
              ),
            ]
        )
    );
  }

  List<Marker> getMarkers(BuildContext context, MyAppState appState, List<Location> locationLista) {
    List<Marker> markerList = [];
    for (Location location in locationLista) {markerList.add(getMarker(context, appState, location));}
    return markerList;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    return getMarkerLayer(context, appState, locationList,);
  }

  MarkerLayer getMarkerLayer(BuildContext context, MyAppState appState, List<Location> locationLista) {
    return MarkerLayer(markers: getMarkers(context, appState, locationLista),);
  }
}