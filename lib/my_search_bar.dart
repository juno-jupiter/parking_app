import 'package:flutter/material.dart';
import 'my_filters_page.dart';

class MySearchBar extends StatelessWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Align(
              alignment: Alignment.center,
              child: Text('hora entrada y salida'),
            ),
            trailing: IconButton.outlined(
              icon: const Icon(Icons.tune),
              onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const MyFiltersPage()));},
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Align(
              alignment: Alignment.center,
              child: Text('rango fechas'),
            ),
            onTap: () {},
          ),
          ListTile(
            titleTextStyle: const TextStyle(color: Colors.white),
            tileColor: Theme.of(context).primaryColor,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15),),),
            title: const Align(alignment: Alignment.center, child: Text('Buscar'),),
            onTap: () {},
          ),
        ],
      ),
    );
  }

}
