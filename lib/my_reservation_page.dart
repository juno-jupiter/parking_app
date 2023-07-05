import 'package:flutter/material.dart';
import 'package:parking_app/my_filters_page.dart';
import 'package:parking_app/my_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/location_card.dart';


class MyReservationPage extends StatefulWidget {
  final Location location;
  final cargoServicio = 0.20;
  final List<bool> estacionamientosIsSelected;
  const MyReservationPage(this.location, this.estacionamientosIsSelected, { super.key });
  @override
  State<MyReservationPage> createState() => _MyReservationPageState();

  bool tieneEstacionamientoSelected(double duration) {
    // Devuelve true si tiene al menos un estacionamiento elegido
    // Calcula el preico total
    location.recalculateTotalCost(duration);
    for (var selected in estacionamientosIsSelected) {if (selected) return true;}
    return false;
  }

}

class _MyReservationPageState extends State<MyReservationPage> {
  double precioTotal = 0.0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    //Image? cardImage;
    //if (widget.location.idLocation > 0) {cardImage = const Image(image: AssetImage("assets/nunoa.jpg"));}

    Duration totalDuration = Duration(minutes: appState.getTotalDuration().toInt());
    int justDays = totalDuration.inDays;
    int justHours = totalDuration.inHours - (justDays * 24);
    int justMinutes = totalDuration.inMinutes - (justHours * 60);
    bool isSelected = widget.tieneEstacionamientoSelected(totalDuration.inMinutes.toDouble());
    precioTotal = 0;
    for (var estacionamiento in widget.location.estacionamientosLista){precioTotal += estacionamiento.precioTotal;}
    double cargoServicio = double.parse((precioTotal * widget.cargoServicio).toStringAsFixed(2));
    precioTotal += cargoServicio;

    String stringTiempoTotal = '';
    if (justDays > 0) stringTiempoTotal = '$justDays dia${(justDays > 1) ? 's' : ''}';
    if (justHours > 0) {
      if (stringTiempoTotal.isNotEmpty && (justMinutes == 0)) {
        stringTiempoTotal = '$stringTiempoTotal y $justHours hora${(justHours > 1) ? 's' : ''}';
      } else if (stringTiempoTotal.isNotEmpty) {
        stringTiempoTotal = '$stringTiempoTotal, $justHours hora${(justHours > 1) ? 's' : ''}';
      } else {
        stringTiempoTotal = '$justHours hora${(justHours > 1) ? 's' : ''}';
      }
    }
    if (justMinutes > 0) {
      if (stringTiempoTotal.isNotEmpty) {
        stringTiempoTotal = '$stringTiempoTotal y';
      } else {
        stringTiempoTotal = '$stringTiempoTotal, $justMinutes minutos${(justMinutes > 1) ? 's' : ''}';
      }
    }

    String stringRangoTiempo = getTimeRangeString(appState, splitTimeDay: false);
    String titulo = 'Solicitar reserva';
    String nombreLocation = widget.location.tituloLocation;
    String lugarGeneralLocation = '${widget.location.calle}, ${widget.location.comuna}';

    AppBar appBar = AppBar(
      leading: const BackButton(),
      title: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(titulo)),
        ],
      ),
    );

    Widget tarjetaNombre = Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: double.infinity,
            child: ListTile(
              title: Text(nombreLocation, style: MyFiltersPage.boldStyle),
              subtitle: Text(lugarGeneralLocation),
              trailing: ratingObjeto(widget.location.ratingLocation),
            ),
          )
      ),
    );

    List<Widget> tarjetaEstacionamientos = [
      const Padding(
          padding: EdgeInsets.only(left: 2.0, right: 2.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: ListTile(title: Text('Tu reserva', style: MyFiltersPage.inputDecoratorLabelStyle,)),
              )
          )
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(
                title: const Text('Fechas', style: MyFiltersPage.boldStyle,),
                subtitle: Text(stringRangoTiempo),
                trailing: const Text('Editar', style: MyFiltersPage.underlinedStyle,),
              ),
            )
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(
                title: Text('Estacionamientos elegidos', style: MyFiltersPage.boldStyle,),
                trailing: Text('Editar', style: MyFiltersPage.underlinedStyle,),
              ),
            )
        ),
      ),
    ];

    List<Widget> detallePrecioEstacionamientos = [];
    int contadorEstacionamiento = 0;
    for (var estacionamiento in widget.location.estacionamientosLista) {
      if (widget.estacionamientosIsSelected[contadorEstacionamiento]) {
        tarjetaEstacionamientos.add(
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                width: double.infinity,
                child: EstacionamientoCard(estacionamiento, contadorEstacionamiento),
              ),
            )
        );
        detallePrecioEstacionamientos.add(
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Expanded(child: Text('\$${estacionamiento.precio} ${appState.moneda} x $stringTiempoTotal')),
                Text('\$${estacionamiento.precioTotal} ${appState.moneda}'),
              ],
            ),
          ),
        );
      }
      contadorEstacionamiento++;
    }
    tarjetaEstacionamientos.add(const Divider());
    if (detallePrecioEstacionamientos.isNotEmpty) {
      detallePrecioEstacionamientos.add(
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(children: [const Expanded(child: Text('Tarifa por servicio')), Text('\$$cargoServicio ${appState.moneda}'),],),
        ),
      );
      detallePrecioEstacionamientos.add(const Divider(color: Colors.black38,));
      detallePrecioEstacionamientos.add(
          Row(
            children: [
              Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: (){},
                      child: RichText(
                        text: TextSpan(
                          text: 'Total (',
                          style: MyFiltersPage.boldStyle,
                          children: <TextSpan>[
                            TextSpan(text: appState.moneda, style: MyFiltersPage.underlinedStyle, ),
                            const TextSpan(text: ')'),
                          ],
                        ),
                      ),
                    ),
                  )
              ),
              Text('\$$precioTotal', style: MyFiltersPage.boldStyle, ),
            ],
          )
      );
      detallePrecioEstacionamientos.add(
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: (){},
                    child: const Text('Más información', style: MyFiltersPage.underlinedStyle,),
                  ),
                ),
              ),
            ]
          ),
      );
    }

    Widget detallesPrecio = Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: double.infinity,
            child: ListTile(
              title: const  Text('Detalles del precio', style: MyFiltersPage.inputDecoratorLabelStyle),
              subtitle: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: detallePrecioEstacionamientos),
              ),
            ),
          )
      ),
    );

    Widget pagarCon = Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: double.infinity,
            child: ListTile(
              title: const Text('Pagar con', style: MyFiltersPage.inputDecoratorLabelStyle),
              subtitle: const Text('Formas de pago'),
              trailing: SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: (){},
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Agrega'),
                  )
                ),
              ),
            ),
          )
      ),
    );

    // Agrega los requisitos adicionales para completar la reserva
    // Eso es tener num telefono configurado y contactar anfitrion si la reserva no es inmediata
    List<Widget> listaRequerimientos = [];
    if (widget.location.inmediata != 1) {
      listaRequerimientos.add(
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: ListTile(
                  title: const Text('Envíale un mensaje al anfitrión', style: MyFiltersPage.inputDecoratorLabelStyle),
                  subtitle: const Text('Debes contactarte con el anfitrión para completar tu reserva'),
                  trailing: SizedBox(
                    width: 100,
                    child: ElevatedButton(
                        onPressed: (){},
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Agrega'),
                        )
                    ),
                  ),
                ),
              )
          ),
        )
      );
    }

    if (appState.numeroTelefonico == null) {
      listaRequerimientos.add(
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: double.infinity,
                  child: ListTile(
                    title: const Text('Número telefónico', style: MyFiltersPage.inputDecoratorLabelStyle),
                    subtitle: const Text('Agrega y confirma tu número de teléfono para recibir actualizaciones tu reserva'),
                    trailing: SizedBox(
                      width: 100,
                      child: ElevatedButton(
                          onPressed: (){},
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Agrega'),
                          )
                      ),
                    ),
                  ),
                )
            ),
          )
      );
    }

    Widget? widgetRequisitos;
    if (listaRequerimientos.isNotEmpty) {
      widgetRequisitos = Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: <Widget>[
            const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: double.infinity,
                  child: ListTile(title: Text('Requisitos para tu reserva', style: MyFiltersPage.inputDecoratorLabelStyle),),
                )
            ),
          ] + listaRequerimientos,
        ),
      );
    }

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

    Widget? widgetNoInmediata;
    if (widget.location.inmediata != 1) {
      widgetNoInmediata = const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(
                leading: Icon(Icons.pending_actions),
                title: Text('No confirmaremos tu reserva hasta que el anfitrion acepte la solicitud (en un plazo de 24 horas)', style: MyFiltersPage.boldStyle),
                subtitle: Text('No te haremos ningun cargo hasta entonces'),
              ),
            )
        ),
      );
    }

    TextStyle underlinedLegal = const TextStyle(decoration: TextDecoration.underline,);
    List<TextSpan> spanTextoLegal = [
      TextSpan(text: 'Reglas del anfritrión de la propiedad', style: underlinedLegal),
      const TextSpan(text: ', '),
      TextSpan(text: 'Política de Reembolso y Asistencia para Cambios en Reservas', style: underlinedLegal, ),
      const TextSpan(text: '. Además doy mi consentimiento para que me pueda '),
      TextSpan(text: 'cobrar a través de mi forma de pago', style: underlinedLegal, ),
      const TextSpan(text: ' si soy responsable de daños.'),
    ];
    if (widget.location.inmediata == 1) {
      spanTextoLegal.add(const TextSpan(text: ' Acepto pagar el monto total indicado si el anfitrión acepta mi solicitud de reserva.'),);
    }

    Widget bottomBar = Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: RichText(
                      text: TextSpan(
                        text: 'Al seleccionar el botón que aparece a continuación, acepto las siguientes políticas: ',
                        style: const TextStyle(fontSize: 12.0, color: Colors.black45),
                        children: spanTextoLegal,
                      ),
                    ),
                  )),
              SizedBox(
                width: 200,
                height: MySearchBar.topMargin,
                child: ElevatedButton(
                  onPressed: isSelected ? () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    appState.selectNavigationIndex(NavigationPageIndex.scheduled);
                  } : null,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Solicitar reserva'),
                  ),
                ),
              )
            ],
          ),
        )
    );

    List<Widget> listViewChildren = [tarjetaNombre, const Divider(),] + tarjetaEstacionamientos;
    listViewChildren = listViewChildren + [detallesPrecio, const Divider(), pagarCon, const Divider()];
    if (widgetRequisitos != null) listViewChildren = listViewChildren + [widgetRequisitos, const Divider()];
    listViewChildren = listViewChildren + [politicaCancelacion, const Divider(),];
    if (widgetNoInmediata != null) listViewChildren = listViewChildren + [widgetNoInmediata, const Divider(),];
    listViewChildren = listViewChildren + [bottomBar];

    return Scaffold(
        appBar: appBar,
        body: Container(
          color: Colors.white,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            children: listViewChildren,
          ),
        ),
    );
  }
}
