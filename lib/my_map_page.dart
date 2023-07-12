import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/location_card.dart';
import 'package:parking_app/my_search_bar.dart';

class MyMapPage extends StatefulWidget {
  final List<Location> locationList;
  const MyMapPage(this.locationList, {super.key});

  @override
  State<MyMapPage> createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  final double dragTriggerRange = 100.0;
  double initialDrag = 0.0;
  double currentDrag = 0.0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    int numEstacionamientos = 0;
    for (var location in widget.locationList){
      location.recalculateTotalCost(appState.getTotalDuration());
      numEstacionamientos += location.estacionamientosLista.length;
    }

    Widget centerSelf = const NearMeButton();

    Widget mapView = FlutterMap(
      options: MapOptions(
        center: appState.posicionUsuario,
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
    '$numEstacionamientos estacionamiento disponible' : '$numEstacionamientos estacionamientos disponibles';

    MySearchBar searchBar = const MySearchBar();
    List<Widget> locationCardViewChildren = [const Expanded(child:Center(child:null),),];

    if (appState.selectedLocation != null) {
      Widget selectedLocationWidget = Stack(children: [
        LocationCard(appState.selectedLocation!),
        Opacity(opacity: 0.5, child: IconButton(onPressed: (){
          appState.toggleLocationMarker(appState.selectedLocation);
        }, icon: const Icon(Icons.cancel)))
      ]);
      locationCardViewChildren.add(selectedLocationWidget);
    }

    Widget openListView = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (DragStartDetails details) {initialDrag = details.globalPosition.dy;},
      onVerticalDragUpdate: (DragUpdateDetails details) {
        currentDrag = details.globalPosition.dy;
        if (currentDrag < (initialDrag - dragTriggerRange)) {appState.toggleListView();}
      },
      child: SizedBox(
        height: MySearchBar.height,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          ),
          child: Center(child: Column(
            children: [
              const Icon(Icons.drag_handle),
              Text(estacionamientosDisponibles, style: const TextStyle(fontWeight: FontWeight.bold,),),
            ],
          ),),
        ),
      )
    );
    if (!appState.isListView){locationCardViewChildren.add(openListView);}

    return Stack(
      children: [
        mapView,
        Column(children: [const SizedBox(height: MySearchBar.topMargin,), searchBar, Align(alignment: Alignment.centerRight, child: centerSelf)],),
        Column(children: locationCardViewChildren,),
      ],
    );
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
    double precioTotal = location.precioMinimo;
    markerString = '\$$precioTotal';

    isSelected = appState.selectedLocation?.idLocation == location.idLocation;
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


class NearMeButton extends StatelessWidget {
  const NearMeButton({super.key});


  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 55, maxWidth: 55),
        child: Center(
          child: ElevatedButton(
            onPressed: ()  {
              appState.toggleSearch();
            },
            child: const Align(alignment: Alignment.centerLeft, child: Icon(Icons.near_me)),
          ),
        ),
      ),
    );
  }
}
