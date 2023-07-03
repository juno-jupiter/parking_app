import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'location_card.dart';
import 'my_search_bar.dart';

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
      onPressed: () {
        appState.toggleMapView();
        },
      child: const Wrap(
          children: [
            Icon(Icons.map, color: Colors.white, size: 16,),
            Text('Mapa', style: TextStyle(color: Colors.white),)
          ]
      ),
    );
    MySearchBar searchBar = const MySearchBar();

    return Stack(
      children: [
        Column(children: [const SizedBox(height: MySearchBar.topMargin,), searchBar,],),
        Column(
          children: [
            const SizedBox(height: MySearchBar.topMargin + MySearchBar.height,),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (DragStartDetails details) {initialDrag = details.globalPosition.dy;},
              onVerticalDragUpdate: (DragUpdateDetails details) {
                currentDrag = details.globalPosition.dy;
                if (currentDrag > (initialDrag + dragTriggerRange)) {appState.toggleMapView();}
              },
              child: const Card(child: SizedBox(height: MySearchBar.height * 0.5, child: Center(child: Icon(Icons.drag_handle),),),),
            ),
            Expanded(
              child: Card(
                child: ListView.builder(
                    padding: const EdgeInsets.all(2),
                    itemCount: widget.locationList.length,
                    itemBuilder: (BuildContext context, int index) {return LocationCard(widget.locationList[index],);}),
              ),
            ),
          ],
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (DragStartDetails details) {initialDrag = details.globalPosition.dy;},
          onVerticalDragUpdate: (DragUpdateDetails details) {
            currentDrag = details.globalPosition.dy;
            if (currentDrag > (initialDrag + dragTriggerRange)) {appState.toggleMapView();}
          },
          child: Column(
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
        )
      ],
    );
  }
}
