import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/location_card.dart';
import 'package:parking_app/my_search_bar.dart';

class MyListViewPage extends StatefulWidget {
  final List<Location> locationList;
  const MyListViewPage(this.locationList, {super.key});

  @override
  State<MyListViewPage> createState() => _MyListViewPageState();
}

class _MyListViewPageState extends State<MyListViewPage> {
  final double dragTriggerRange = 400.0;
  double initialDrag = 0.0;
  double currentDrag = 0.0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    Widget goToMapButton = ElevatedButton(
      onPressed: () {appState.toggleMapView();},
      child: const Wrap(
          children: [
            Icon(Icons.map, color: Colors.white, size: 16,),
            Text('Mapa', style: TextStyle(color: Colors.white),)
          ]
      ),
    );
    MySearchBar searchBar = const MySearchBar();

    return SizedBox(
      child: Stack(
        children: [
          Column(children: [const SizedBox(height: MySearchBar.topMargin,), searchBar,],),
          Column(
            children: [
              const SizedBox(height: MySearchBar.topMargin * 3.0,),
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(2),
                    itemCount: widget.locationList.length,
                    itemBuilder: (BuildContext context, int index) {return LocationCard(widget.locationList[index],);}
                ),
              ),
            ],
          ),
          Column(
            children: [
              Expanded(child: Container(child: null,)),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),),
                    child: goToMapButton
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
