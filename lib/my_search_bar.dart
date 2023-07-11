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
    String stringRangoTiempo = getTimeRangeString(appState);
    SizedBox searchBarIcon({Alignment alignment = Alignment.center, IconData? icon, Color color = Colors.black, Color? borderColor, Function()? onTap}) {
      return SizedBox(
        width: 50,
        child: Align(
          alignment: alignment,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: (borderColor != null) ? borderColor : color),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(icon, color: color,),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60),),
        child: ListTile(
          leading: searchBarIcon(
            alignment: Alignment.center,
            icon: Icons.search,
            color: Colors.black38,
            borderColor: Colors.white10,
            onTap: () {},
          ),
          title: Align(
            alignment: Alignment.center,
            child: Text(stringRangoTiempo),
          ),
          trailing: searchBarIcon(
            alignment: Alignment.center,
            icon: Icons.tune,
            color: Colors.black38,
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {return filtersPage;},
                enableDrag: true,
                clipBehavior: Clip.hardEdge,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
              );
            },
          ),
        ),
      ),
    );
  }
}
