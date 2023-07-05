import 'package:flutter/material.dart';
import 'package:parking_app/my_filters_page.dart';
import 'package:parking_app/my_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_reservation_page.dart';

Widget ratingObjeto(double rating) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 50),
    child: Center(
      child: SizedBox(
        width: 50,
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.black, size: 15,),
            Text('$rating', style: LocationCard.ratingStyle,),
          ],
        ),
      ),
    ),
  );
}

class LocationPage extends StatefulWidget {
  final Location location;
  const LocationPage(this.location, { super.key });
  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  List<bool> estacionamientosIsSelected = [];
  double precioTotal = 0.0;

  toggleEstacionamientoSelected(bool value, int index) {
    if (estacionamientosIsSelected.isEmpty) {
      estacionamientosIsSelected = List<bool>.filled(widget.location.estacionamientosLista.length, false);
    }
    estacionamientosIsSelected[index] = value;
    setState(() {
      estacionamientosIsSelected = List<bool>.of(estacionamientosIsSelected);
    });
  }

  bool tieneEstacionamientoSelected(double duration) {
    // Devuelve true si tiene al menos un estacionamiento elegido
    // Calcula el preico total
    widget.location.recalculateTotalCost(duration);
    precioTotal = 0;
    int contadorEstacionamiento = 0;
    for (var selected in estacionamientosIsSelected) {
      if (selected) precioTotal += widget.location.estacionamientosLista[contadorEstacionamiento].precioTotal;
      contadorEstacionamiento++;
    }
    bool isSelected = (precioTotal > 0);
    if (!isSelected) precioTotal = widget.location.precioMinimo;
    return isSelected;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    bool isFav = appState.favLocations.contains(widget.location.idLocation);
    Image? cardImage;
    if (widget.location.idLocation > 0) {cardImage = const Image(image: AssetImage("assets/nunoa.jpg"));}
    int estacionamientos = widget.location.estacionamientosLista.length;
    String stringDisponibilidad = '$estacionamientos estacionamientos disponibles';
    if (estacionamientos == 1) {stringDisponibilidad = '1 estacionamiento disponible';}

    bool isSelected = false;
    if (estacionamientosIsSelected.isEmpty) estacionamientosIsSelected = List<bool>.filled(estacionamientos, false);
    isSelected = tieneEstacionamientoSelected(appState.getTotalDuration());

    String precioMinimo = '\$${widget.location.precioMinimo} ${appState.moneda}';
    String precioCompleto = '\$$precioTotal ${appState.moneda}';
    String stringRangoTiempo = getTimeRangeString(appState, splitTimeDay: false);
    List<String> stringRangoTiempoSplit = getTimeRangeString(appState).split('\n');
    String titulo = widget.location.tituloLocation;
    String nombreLocation = widget.location.tituloLocation;
    String lugarGeneralLocation = '${widget.location.calle}, ${widget.location.comuna}';
    String nombreAnfitrion = (widget.location.anfitrion != null) ? widget.location.anfitrion!.nombreAnfitrion : '';
    Color primaryColor = Theme.of(context).primaryColor;

    AppBar appBar = AppBar(
      leading: const BackButton(),
      title: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(titulo)),
          Align(alignment: Alignment.centerLeft, child: Text(stringRangoTiempo, style: const TextStyle(fontSize: 10))),
        ],
      ),
      actions: [
        IconButton(onPressed: () {appState.toggleFavoriteLocation(widget.location);}, icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),)
      ],
    );

    Widget galeriaImagenes = SizedBox(
        width: double.infinity, height: 300,
        child: FittedBox(
          fit: BoxFit.fill,
          child: cardImage,
        )
    );

    Widget tarjetaNombre = Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: double.infinity,
          child: ListTile(
            title: Text(nombreLocation, style: MyFiltersPage.inputDecoratorLabelStyle),
            subtitle: Text('$lugarGeneralLocation\n$stringDisponibilidad, desde $precioMinimo'),
            trailing: ratingObjeto(widget.location.ratingLocation),
          ),
        )
      ),
    );

    List<Widget> listaCaracteristicas = [
      Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: ListTile(
                  title: Text('Tipo de propiedad: ${widget.location.tipoLocation}', style: MyFiltersPage.inputDecoratorLabelStyle),
                ),
              )
          )
      ),
    ];
    int numCaracLoc = 0;
    for (var valor in [widget.location.inmediata, widget.location.autonoma, widget.location.acceso,]) {
      if (valor == 1) {
        listaCaracteristicas.add(
            Padding(
                padding: const EdgeInsets.all(4.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: double.infinity,
                      child: ListTile(
                        title: Text(Location.listaOpcionesReservacion[numCaracLoc], style: MyFiltersPage.inputDecoratorLabelStyle),
                        subtitle: Text(Location.listaSubtitulosOpcionesReservacion[numCaracLoc]),
                      ),
                    )
                )
            )
        );
        numCaracLoc++;
      }
    }
    listaCaracteristicas.add(const Divider());

    Widget? tarjetaAnfitrion;
    if (widget.location.anfitrion != null) {
      tarjetaAnfitrion = Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ListTile(
                      title: Text('Anfitrión:\n$nombreAnfitrion', style: MyFiltersPage.inputDecoratorLabelStyle),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            const Icon(Icons.account_circle, size: 50,),
                            ratingObjeto(widget.location.anfitrion!.ratingAnfitrion),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      height: MySearchBar.topMargin,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Contactar anfitrión', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ),
                ],
              )
          )
      );
    }

    Widget tarjetaUbicacion = Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Dónde vas a estar', style: MyFiltersPage.inputDecoratorLabelStyle,),
                  subtitle: Text(lugarGeneralLocation, style: LocationCard.boldStyle),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children:[
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(10))),
                          child: Center(child: Icon(Icons.place, size: 50, color: primaryColor,),),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: MySearchBar.topMargin,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Te proporcionaremos la ubicación exacta una vez que reserves'),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );

    Widget tarjetaDisponibilidad = Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: double.infinity,
            child: ListTile(
              title: const Text('Disponibilidad', style: MyFiltersPage.inputDecoratorLabelStyle,),
              subtitle: Text(stringRangoTiempo, style: MyFiltersPage.underlinedStyle,),
              trailing: const Icon(Icons.navigate_next),
            ),
          )
      ),
    );

    List<Widget> tarjetaEstacionamientos = [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(
                title: const Text('Elige tu(s) estacionamiento(s)', style: MyFiltersPage.inputDecoratorLabelStyle,),
                subtitle: Text(stringDisponibilidad,),
              ),
            )
        ),
      ),
    ];
    int contadorEstacionamiento = 0;
    for (var estacionamiento in widget.location.estacionamientosLista) {
      tarjetaEstacionamientos.add(
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              width: double.infinity,
              child: EstacionamientoCard(
                estacionamiento,
                contadorEstacionamiento,
                isSelected: estacionamientosIsSelected[contadorEstacionamiento],
                onChangedCallback: toggleEstacionamientoSelected, ),
            ),
          )
      );
      contadorEstacionamiento++;
    }
    tarjetaEstacionamientos.add(const Divider());

    Widget politicaCancelacion = const Padding(
      padding: EdgeInsets.all(4.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: double.infinity,
            child: ListTile(
              title: Text('Política de cancelación', style: MyFiltersPage.inputDecoratorLabelStyle),
              subtitle: Text('Esta reserva no es reembolsable'),
              trailing: Icon(Icons.navigate_next),
            ),
          )
      ),
    );

    Widget reportarAnuncio = const Padding(
      padding: EdgeInsets.all(4.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: double.infinity,
            child: ListTile(
              leading: Icon(Icons.flag),
              title: Text('Reportar este anuncio', style: MyFiltersPage.underlinedStyle),
            ),
          )
      ),
    );

    List<Widget> listViewChildren = [galeriaImagenes, const Divider(), tarjetaNombre, const Divider(),] + listaCaracteristicas;
    listViewChildren = listViewChildren + [tarjetaUbicacion, const Divider()];
    if (tarjetaAnfitrion != null) listViewChildren = listViewChildren + [tarjetaAnfitrion, const Divider()];
    listViewChildren = listViewChildren + [tarjetaDisponibilidad, const Divider()] + tarjetaEstacionamientos;
    listViewChildren = listViewChildren + [politicaCancelacion, const Divider(), reportarAnuncio];

    Widget bottomBar = Container(
      height: MySearchBar.height,
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), color: Colors.white,),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: 180,
              child: Column(
                children: [
                  Text(isSelected ? precioCompleto : 'Desde $precioMinimo', style: LocationCard.boldStyle,),
                  Text(stringRangoTiempoSplit[0], style: MyFiltersPage.underlinedStyle,),
                  Text(stringRangoTiempoSplit[1], style: MyFiltersPage.underlinedStyle,),
                ],
              ),
            ),
            const Spacer(flex: 1,),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: isSelected ? () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> MyReservationPage(widget.location, estacionamientosIsSelected)));
                } : null,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Reservar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      children: listViewChildren,
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomBar,
        ],
      )
    );
  }
}

class EstacionamientoCard extends StatelessWidget {
  final Estacionamiento estacionamiento;
  final bool? isSelected;
  final Function? onChangedCallback;
  final int index;
  const EstacionamientoCard(this.estacionamiento, this.index, { super.key, this.isSelected, this.onChangedCallback,  });

  Card getEstacionamientoCard(BuildContext context, MyAppState appState) {
    //bool isFav = appState.favLocations.contains(estacionamiento.idEstacionamiento);
    Image? cardImage;
    if (estacionamiento.idEstacionamiento > 0) {cardImage = const Image(image: AssetImage("assets/nunoa.jpg"));}

    double precioTotal = estacionamiento.precioTotal;
    String precioCompleto = '\$$precioTotal ${appState.moneda}';
    String stringRangoTiempo = getTimeRangeString(appState, splitTimeDay: false);
    String titulo = estacionamiento.nombreEstacionamiento;
    double rating = estacionamiento.ratingEstacionamiento;

    Widget title = Row(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: Text(titulo, style: LocationCard.boldStyle,)),
              Align(alignment: Alignment.centerLeft, child: ratingObjeto(rating),),
            ],
          ),
        ),
      ],
    );

    Widget subtitle = Row(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: Text(stringRangoTiempo,)),
              Align(alignment: Alignment.centerLeft, child: Text('Estacionamiento ${estacionamiento.tipoEstacionamiento}',)),
              Align(alignment: Alignment.centerLeft, child: Text(precioCompleto, style: LocationCard.boldStyle,)),
            ],
          ),
        ),
      ],
    );

    Widget tile;
    if ((isSelected != null) && (onChangedCallback != null)) {
      tile = CheckboxListTile (value: isSelected, onChanged: (bool? value){onChangedCallback!(value, index);}, title: title, subtitle: subtitle,);
    } else {
      tile = ListTile(title: title, subtitle: subtitle,);
    }

    return Card(
        clipBehavior: Clip.hardEdge,
        child: Row(
            children: [
              ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: SizedBox(width: 120, height: double.infinity, child: FittedBox(clipBehavior: Clip.hardEdge, fit: BoxFit.fill, child: cardImage,))
              ),
              Expanded(child: tile),
            ]
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);
    return getEstacionamientoCard(context, appState);
  }

}

class LocationCard extends StatefulWidget {
  static const TextStyle boldStyle = TextStyle(fontWeight: FontWeight.bold,);
  static const TextStyle ratingStyle = TextStyle(color: Colors.black,);
  final Location location;
  const LocationCard(this.location, { super.key });
  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  Card getLocationCard(BuildContext context, MyAppState appState) {
    widget.location.recalculateTotalCost(appState.getTotalDuration());

    bool isFav = appState.favLocations.contains(widget.location.idLocation);
    Image? cardImage;
    if (widget.location.idLocation > 0) {cardImage = const Image(image: AssetImage("assets/nunoa.jpg"));}
    int estacionamientos = widget.location.estacionamientosLista.length;
    String stringDisponibilidad = '$estacionamientos estacionamientos disponibles';
    if (estacionamientos == 1) {stringDisponibilidad = '1 estacionamiento disponible';}

    double precioTotal = widget.location.precioMinimo;
    String precioCompleto = (widget.location.estacionamientosLista.length > 1) ? 'Desde \$$precioTotal ${appState.moneda}' : '\$$precioTotal ${appState.moneda}';
    String stringRangoTiempo = getTimeRangeString(appState);
    String titulo = widget.location.tituloLocation;
    double rating = widget.location.ratingLocation;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        splashColor: Theme.of(context).primaryColor.withAlpha(30),
        onTap: () {
          appState.toggleLocationPage(widget.location);
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> LocationPage(widget.location,)));
          },
        child: Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
                child: SizedBox(width: 150, height: double.infinity, child: FittedBox(clipBehavior: Clip.hardEdge, fit: BoxFit.fill, child: cardImage,))
            ),
            Expanded(
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Align(alignment: Alignment.topLeft, child: Text(titulo, style: LocationCard.boldStyle,),),
                          Align(alignment: Alignment.topLeft, child: Text(stringDisponibilidad)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {appState.toggleFavoriteLocation(widget.location);},
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Align(alignment: Alignment.bottomLeft, child: Text(stringRangoTiempo,)),
                          Align(alignment: Alignment.bottomLeft, child: Text(precioCompleto, style: LocationCard.boldStyle,)),
                        ],
                      ),
                    ),
                    ratingObjeto(rating),
                  ],
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
