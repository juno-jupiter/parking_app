import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_filters_page.dart';
import 'package:parking_app/my_favorites_page.dart';

class BottomSheetColeccionFavoritos extends StatelessWidget {
  static const double iconSize = 30.0;
  final Location location;
  final List<ColeccionFavoritos> listadoColeccionesFavoritos;

  const BottomSheetColeccionFavoritos({super.key, required this.location, required this.listadoColeccionesFavoritos,});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    Widget titleBar = Center(
      child: ListTile(
        leading: IconButton.outlined(
          icon: const Icon(Icons.close, size: iconSize,),
          onPressed: () {
            appState.closeCreatingColeccion();
          },
        ),
        title: const Text('Tus favoritos'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
      ),
    );

    List<Widget> listViewChildren = [ColeccionFavoritosCard(coleccionFavoritos: null, location: location,)];
    if (listadoColeccionesFavoritos.isEmpty) {
      // Abrir popup crear coleccion
    } else {
      for (var favoritos in listadoColeccionesFavoritos) {listViewChildren.add(ColeccionFavoritosCard(location: location, coleccionFavoritos: favoritos,));}
    }

    return Material(
      child: Column(
        children: [
          titleBar,
          const Divider(),
          ListView(
            shrinkWrap: true,
            children: listViewChildren,
          ),
        ],
      ),
    );
  }
}

class ColeccionFavoritosCard extends StatelessWidget {
  static const TextStyle boldStyle = TextStyle(fontWeight: FontWeight.bold,);
  final ColeccionFavoritos? coleccionFavoritos;
  final Location? location;

  const ColeccionFavoritosCard({super.key, this.coleccionFavoritos, this.location});

  Card getLocationCard(BuildContext context, MyAppState appState) {
    Widget? cardImage;
    if (coleccionFavoritos == null) {
      cardImage = Container(color: Colors.white, child: const Icon(Icons.add, size: BottomSheetColeccionFavoritos.iconSize,),);
    }
    else if (coleccionFavoritos!.favoritosLista.isNotEmpty) {
      cardImage = const Image(image: AssetImage("assets/nunoa.jpg"));
    } else {
      cardImage = const SizedBox(width: 200, height: 200, child: null,);
    }

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Theme.of(context).primaryColor.withAlpha(30),
        onTap: () {
          if ((coleccionFavoritos == null) && (location != null)) {
            appState.openCreatingColeccion();
          } else if ((location == null) && (coleccionFavoritos != null)) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> FavoriteCollectionPage(coleccionFavoritos!))).then((value) => appState.closeCreatingColeccion());
          }
        },
        child: Row(
          children: [
            ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 100),
                child: Container(
                    color: Colors.grey,
                    width: 150, height: double.infinity,
                    child: FittedBox(clipBehavior: Clip.hardEdge, fit: BoxFit.fill, child: cardImage,)
                )
            ),
            Expanded(
              child: ListTile(
                title: Text(
                  (coleccionFavoritos != null) ? coleccionFavoritos!.nombreColeccionFavoritos : 'Crear una nueva lista de favoritos',
                  style: MyFiltersPage.inputDecoratorLabelStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    return getLocationCard(context, appState);
  }
}