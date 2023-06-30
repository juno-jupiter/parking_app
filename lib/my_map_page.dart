import 'package:flutter/material.dart';
import 'package:parking_app/my_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'my_app_state.dart';
import 'location_card.dart';

class MyMapPage extends StatefulWidget {
  const MyMapPage({super.key});

  @override
  State<MyMapPage> createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    Widget mapView = FlutterMap(
      options: MapOptions(
        center: const LatLng(-33.455941054704866, -70.59368311749424),
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
        MarkerLayer(
          markers: [
            Marker(
                point: const LatLng(-33.455941054704866, -70.59368311749424),
                width: 120,
                height: 80,
                builder: (context) => Stack(
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: () => appState.toggleLocationCard(),
                        child: const Text('\$1000/h', style: TextStyle(color: Colors.black),),
                      ),
                    ]
                )
            ),
          ],
        ),
      ],
    );

    Widget searchBar = const Column(children: [SizedBox(height: 36,), MySearchBar(),]);
    List<Widget> stackChildren = [mapView, searchBar];
    if (appState.openedLocationCard) {
      stackChildren.add(const Column(children: <Widget>[Expanded(child:Center(child:null),), LocationCard()]));
    }
    return Stack(children: stackChildren,);
  }
}