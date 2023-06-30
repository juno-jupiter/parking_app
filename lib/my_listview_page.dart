import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'location_card.dart';
import 'my_search_bar.dart';

class MyListViewPage extends StatefulWidget {
  const MyListViewPage({super.key});

  @override
  State<MyListViewPage> createState() => _MyListViewPageState();
}

class _MyListViewPageState extends State<MyListViewPage> {
  bool isListView = true;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    Widget goToMapButton = ElevatedButton(
      onPressed: () {appState.toggleMapView();},
      child: const Wrap(
          children: [
            Icon(Icons.map, color: Colors.white,),
            Text('Mapa', style: TextStyle(color: Colors.white),)
          ]
      ),
    );

    return Stack(
      children: [
        Column(
          children: [
            const MySearchBar(),
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    return const LocationCard();
                  }
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
        )
      ],
    );
  }
}
