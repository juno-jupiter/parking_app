import 'package:flutter/material.dart';
import 'my_filters_page.dart';
import 'my_app_state.dart';
import 'package:provider/provider.dart';

class MySearchBar extends StatelessWidget {
  static const double height = 60.0;
  static const double topMargin = height * 0.75;
  static const double iconSize = height * 0.5;
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    String stringRangoTiempo = getTimeRangeString(appState, splitTimeDay: false);
    return SizedBox(
      height: height,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60),),
        child: ListTile(
          leading: IconButton.outlined(
            icon: const Icon(Icons.search, size: iconSize,),
            onPressed: () {},
          ),
          title: Align(
            alignment: Alignment.center,
            child: Text(stringRangoTiempo),
          ),
          trailing: IconButton.outlined(
            icon: const Icon(Icons.tune, size: iconSize,),
            onPressed: () {
              Scaffold.of(context).showBottomSheet(
                (BuildContext context) {return const MyFiltersPage();},
                clipBehavior: Clip.hardEdge,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
              );
              },
          ),
          onTap: () {},
        )
      ),
    );
  }

}
