import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_filters_page.dart';


class MySearchBar extends StatelessWidget {
  static const double height = 70.0;
  static const double topMargin = height * 0.75;
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    MyFiltersPage filtersPage = MyFiltersPage(searchFilters: appState.searchFilters);

    String stringRangoTiempo = getTimeRangeString(appState, splitTimeDay: false);
    return SizedBox(
      height: height,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60),),
        child: ListTile(
          leading: SizedBox(
            width: 50,
            child: const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.search,)
            ),
          ),
          title: Align(
            alignment: Alignment.center,
            child: Text(stringRangoTiempo),
          ),
          trailing: SizedBox(
            width: 50,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle,border: Border.all(color: Colors.black38),),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.tune, color: Colors.black38,),
                  ),
                ),
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {return filtersPage;},
                    enableDrag: true,
                    clipBehavior: Clip.hardEdge,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
                  ).whenComplete(() async {appState.toggleSearch(); });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
