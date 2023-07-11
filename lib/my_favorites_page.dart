import 'package:flutter/material.dart';
import 'package:parking_app/location_card.dart';
import 'package:parking_app/update_favorites.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_filters_page.dart';

class MyFavoritesPage extends StatelessWidget {
  const MyFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    List<ColeccionFavoritos> listaColeccionesFavoritos = [];
    if (appState.perfilUsuario != null) listaColeccionesFavoritos = appState.perfilUsuario!.listadoColeccionesFavoritos;
    Widget favoriteContainer;

    if (listaColeccionesFavoritos.isEmpty) {
      favoriteContainer = Container(
        color: Colors.white,
        child: const Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Crea tu primera lista de favoritos', style: MyFiltersPage.inputDecoratorLabelStyle,),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Mientras buscas, toca el ícono de corazón para guardar los lugares y estacionamientos que más te gusten en tus favoritos',
                  style: TextStyle(color: Colors.grey),),
              ),
            ),
          ],
        ),
      );
    } else {
      List<Widget> listViewChildren = [];
      for (var favoritos in listaColeccionesFavoritos.reversed) {listViewChildren.add(ColeccionFavoritosCard(coleccionFavoritos: favoritos,));}

      double totalHeight = MediaQuery.of(context).size.height;
      favoriteContainer = Container(
        height: totalHeight,
        color: Colors.white,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: listViewChildren,
        ),
      );
    }
    return favoriteContainer;
  }

}


class FavoriteCollectionPage extends StatefulWidget {
  final ColeccionFavoritos coleccionFavoritos;
  const FavoriteCollectionPage(this.coleccionFavoritos, { super.key });
  @override
  State<FavoriteCollectionPage> createState() => _FavoriteCollectionPageState();
}

class _FavoriteCollectionPageState extends State<FavoriteCollectionPage> {
  final myTextController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    AppBar appBar = AppBar(
      leading: const BackButton(),
      title: Align(alignment: Alignment.centerLeft, child: Text(widget.coleccionFavoritos.nombreColeccionFavoritos)),
      actions: [
        IconButton(onPressed: () async {
          await appState.openUpdateColeccion();
        },
          icon: const Icon(Icons.more_vert),
        )
      ],
    );
    List<Widget> listViewChildren = [];
    for (var favorito in widget.coleccionFavoritos.favoritosLista) {
      if (favorito.location != null) listViewChildren.add(LocationCard(favorito.location!));
    }

    List<Widget> stackChildren = [
      Scaffold(
          appBar: appBar,
          body: Container(
            color: Colors.white,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              children: listViewChildren,
            ),
          ),
      )
    ];
    double totalHeight = MediaQuery.of(context).size.height;
    if (appState.isUpdatingColeccionFavorito) {
      stackChildren.add(
        Stack(
          children: [
            SizedBox(
              height: totalHeight,
              child: Material(
                color: Colors.black54,
                child: InkWell(onTap: (){
                  setState(() {
                    myTextController.text = widget.coleccionFavoritos.nombreColeccionFavoritos;
                  });
                  appState.closeCreatingColeccion();
                },),
              ),
            ),
            Column(
              children: [
                Expanded(child: Container(child: null)),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: totalHeight * 0.35),
                    child: SizedBox(
                      height: totalHeight * 0.35,
                      child: Card(
                        color: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),),
                        child: Column(
                          children: [
                            ListTile(
                              leading: IconButton(
                                onPressed: () {
                                  setState(() {
                                    myTextController.text = widget.coleccionFavoritos.nombreColeccionFavoritos;
                                  });
                                  appState.closeCreatingColeccion();
                                },
                                icon: const Icon(Icons.close),
                              ),
                              title: const Text('Configuración', style: LocationCard.boldStyle,),
                              trailing: TextButton(
                                onPressed: () {},
                                child: const Text('Eliminar', style: MyFiltersPage.underlinedStyle),
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: Column(
                                children: [
                                  const Spacer(flex: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: TextField(
                                      controller: myTextController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Nombre de la lista de favoritos',
                                        hintText: 'Nombre de la lista de favoritos',
                                        helperText: 'Máximo 50 caracteres',
                                      ),
                                    ),
                                  ),
                                  const Spacer(flex: 1),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  TextButton(
                                      onPressed: (){
                                        setState(() {
                                          myTextController.text = widget.coleccionFavoritos.nombreColeccionFavoritos;
                                        });
                                        appState.closeCreatingColeccion();
                                        },
                                      child: const Text('Cancelar', style: MyFiltersPage.underlinedStyle,),
                                  ),
                                  const Spacer(flex: 1,),
                                  ElevatedButton(
                                      onPressed: () async {
                                        if (myTextController.text.isEmpty) return;
                                        // Guardar cambios
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Guardar', style: TextStyle(color: Colors.white),),
                                      )
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      setState(() {
        myTextController.text = widget.coleccionFavoritos.nombreColeccionFavoritos;
      });
    }

    return Stack(children: stackChildren,);
  }
}