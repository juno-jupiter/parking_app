import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_search_bar.dart';
import 'package:sqflite/sqflite.dart';

class MyFiltersPage extends StatefulWidget {
  final SearchFilters searchFilters;
  static const TextStyle inputDecoratorLabelStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20,);
  static const TextStyle boldStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.bold,);
  static const TextStyle underlinedStyle = TextStyle(color: Colors.black, decoration: TextDecoration.underline,);
  static const BoxConstraints toggleButtonBoxConstrains = BoxConstraints(minHeight: 40.0,minWidth: 80.0,);
  static const BorderRadius toggleButtonBorderRadius = BorderRadius.all(Radius.circular(8));

  const MyFiltersPage({super.key, required this.searchFilters,});

  @override
  State<MyFiltersPage> createState() => _MyFiltersPageState();
}

class _MyFiltersPageState extends State<MyFiltersPage> {
  static const double iconSize = 30.0;
  static const List<String> listaIdiomas = ['español', 'inglés', 'portugués', 'francés', 'alemán', 'japonés', 'italiano', 'ruso', 'chino (simplificado)', 'árabe'];
  static const List<String> listaOpcionesReservacion = ['Reserva inmediata', 'Llegada autónoma', 'Acceso sin escaleras'];
  static const List<String> listaSubtitulosOpcionesReservacion = [
    'Reserva sin esperar a que responda el anfitrión',
    'Fácil acceso a la propiedad al llegar',
    'Se puede acceder al estacionamientos sin tener que subir o bajar escaleras'
  ];

  bool initialSearch = true;
  RangeValues rangoPrecios = const RangeValues(0, 100);
  List<bool> idiomasElegidos = List<bool>.filled(listaIdiomas.length, false);
  List<bool> opcionesReservacionElegidas = List<bool>.filled(listaOpcionesReservacion.length, false);
  int numeroEstacionamientos = 0;
  List<bool> tipoPropiedadIsSelected = [true, false, false];
  List<bool> tipoEstacionamientoIsSelected = [true, false, false];
  bool mostrarMasIdiomas = false;

  List<Location> tempLocationList = [];
  int tempNumEstacionamientos = 0;
  bool isDisposed = false;

  void selectToggleButtonOnlyOne(List<bool> selectedList, int index) {
    int falseNum = 0;
    if (index == 0) selectedList[index] = !selectedList[index];
    for (var i = 0; i < selectedList.length; i++){
      if (i == index) {selectedList[i] = !selectedList[i];
      } else {selectedList[i] = false;}
      if (!selectedList[i]) falseNum++;
    }
    if ((falseNum == selectedList.length) || (falseNum == 0)) selectedList[0] = true;
  }
  void selectToggleButtonAny(List<bool> selectedList, int index) {selectedList[index] = !selectedList[index];}

  Future<void> recalculateLocationList(Database database, DateTime fechaHoraDesde, DateTime fechaHoraHasta) async{
    if (isDisposed) return ;
    int nuevoNumEstacionamientos = 0;
    double totalDuration = getTotalDuration(fechaHoraDesde, fechaHoraHasta);
    var searchFilters = SearchFilters(
      fechaHoraDesde, fechaHoraHasta, rangoPrecios: rangoPrecios, idiomasElegidos: idiomasElegidos,
      opcionesReservacionElegidas: opcionesReservacionElegidas, numeroEstacionamientos: numeroEstacionamientos, tipoPropiedadIsSelected: tipoPropiedadIsSelected,
      tipoEstacionamientoIsSelected: tipoEstacionamientoIsSelected,
    );
    List<Location> locationList = await searchFilters.getLocationList(database);
    for (var location in locationList){
      location.recalculateTotalCost(totalDuration);
      nuevoNumEstacionamientos += location.estacionamientosLista.length;
    }
    setState(() {tempNumEstacionamientos = nuevoNumEstacionamientos;});
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyAppState appState = Provider.of<MyAppState>(context, listen: true);
    // Carga los valores del filtro guardado en widget.searchFilters
    if (initialSearch) {
      initialSearch = false;
      rangoPrecios = widget.searchFilters.rangoPrecios;
      idiomasElegidos = List.of(widget.searchFilters.idiomasElegidos);
      opcionesReservacionElegidas = List.of(widget.searchFilters.opcionesReservacionElegidas);
      numeroEstacionamientos = widget.searchFilters.numeroEstacionamientos;
      tipoPropiedadIsSelected = List.of(widget.searchFilters.tipoPropiedadIsSelected);
      tipoEstacionamientoIsSelected = List.of(widget.searchFilters.tipoEstacionamientoIsSelected);
    }

    Database database = appState.database;
    DateTime timeFrom = DateTime(appState.fechaHoraDesde.year, appState.fechaHoraDesde.month, appState.fechaHoraDesde.day, appState.fechaHoraDesde.hour,  appState.fechaHoraDesde.minute);
    DateTime timeTo = DateTime(appState.fechaHoraHasta.year, appState.fechaHoraHasta.month, appState.fechaHoraHasta.day, appState.fechaHoraHasta.hour,  appState.fechaHoraHasta.minute);

    if (!isDisposed) {
      // Al final de este frame recarga la busqueda temporal de estacionamientos, para ofrecer  cuantos hay disponibles
      WidgetsBinding.instance.addPostFrameCallback((_) async {recalculateLocationList(database, timeFrom, timeTo);});
    }

    Color primaryColor = Theme.of(context).primaryColor;
    double totalHeight = MediaQuery.of(context).size.height;
    double bodyHeight = totalHeight - MySearchBar.height;

    List<Widget> listaIdiomasCheckbox = [];
    int idiomasMostrados = mostrarMasIdiomas ? listaIdiomas.length : 3;
    for (var i = 0; i < idiomasMostrados; i++) {
      listaIdiomasCheckbox.add(CheckboxListTile(
            title: Text(listaIdiomas[i]),
            value: idiomasElegidos[i],
            onChanged:(bool? value) {setState(() {
              idiomasElegidos[i] = value ?? false;
            });},
          ));
    }
    // Boton mostrar mas/mostrar menos
    listaIdiomasCheckbox.add(
      TextButton(
          onPressed: (){setState(() {mostrarMasIdiomas = !mostrarMasIdiomas;});},
          child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                children: [
                  Text(mostrarMasIdiomas ? 'Mostrar menos' : 'Mostrar más', style: MyFiltersPage.underlinedStyle,),
                  Icon(mostrarMasIdiomas ? Icons.expand_less : Icons.expand_more, color: Colors.black,),
                ],
              ),
          ),
      )
    );

    List<Widget> listaOpcionesReservacionSwitch = [];
    for (var i = 0; i < listaOpcionesReservacion.length; i++) {
      listaOpcionesReservacionSwitch.add(SwitchListTile(
          title: Text(listaOpcionesReservacion[i]),
          subtitle: Text(listaSubtitulosOpcionesReservacion[i]),
          value: opcionesReservacionElegidas[i],
          onChanged: (bool value) {setState(() {opcionesReservacionElegidas[i] = value;});},
        ));
    }

    NavigatorState navigator = Navigator.of(context);

    closeAndResetSearch() async {
      isDisposed = true;
      await appState.resetSearchFilters();
      navigator.pop();
    }

    Widget titleBar = SizedBox(
      child: Center(
        child: ListTile(
          leading: IconButton.outlined(
            icon: const Icon(Icons.close, size: iconSize,),
            onPressed: () {
              isDisposed = true;
              navigator.pop();
            },
          ),
          title: const Text('Filtros'),
          titleTextStyle: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );

    Widget widgetRangoDePrecios = Padding(
      padding: const EdgeInsets.all(8.0),
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Rango de precios', labelStyle: MyFiltersPage.inputDecoratorLabelStyle),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                RangeSlider(
                  values: rangoPrecios,
                  max: 100,
                  onChanged: (RangeValues values) {setState(() {rangoPrecios = values;});},
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Mínimo', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const Spacer(flex: 1,),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        decoration: const InputDecoration(labelText: 'Máximo', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Widget widgetTipoDePropiedad = Padding(
      padding: const EdgeInsets.all(8.0),
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Tipo de propiedad', labelStyle: MyFiltersPage.inputDecoratorLabelStyle),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ToggleButtons(
              onPressed: (int index) {setState(() {selectToggleButtonOnlyOne(tipoPropiedadIsSelected, index);});},
              borderRadius: MyFiltersPage.toggleButtonBorderRadius,
              fillColor: primaryColor,
              selectedColor: Colors.white,
              textStyle: MyFiltersPage.boldStyle,
              constraints: MyFiltersPage.toggleButtonBoxConstrains,
              isSelected: tipoPropiedadIsSelected,
              children: const [Text('Todo'), Text('Casa'), Text('Edificio'),],
            ),
          ),
        ),
      ),
    );
    Widget widgetTipoDeEstacionamiento = Padding(
      padding: const EdgeInsets.all(8.0),
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Tipo de estacionamiento', labelStyle: MyFiltersPage.inputDecoratorLabelStyle),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ToggleButtons(
              onPressed: (int index) {setState(() {selectToggleButtonAny(tipoEstacionamientoIsSelected, index);});},
              borderRadius: MyFiltersPage.toggleButtonBorderRadius,
              fillColor: primaryColor,
              selectedColor: Colors.white,
              textStyle: MyFiltersPage.boldStyle,
              constraints: MyFiltersPage.toggleButtonBoxConstrains,
              isSelected: tipoEstacionamientoIsSelected,
              children: const [Text('Auto'), Text('Moto'), Text('XL'),],
            ),
          ),
        ),
      ),
    );
    Widget widgetOpcionesDeReserva = Padding(
      padding: const EdgeInsets.all(8.0),
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Opciones de reserva', labelStyle: MyFiltersPage.inputDecoratorLabelStyle),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: listaOpcionesReservacionSwitch,
          ),
        ),
      ),
    );
    Widget widgetIdiomaPersona = Padding(
      padding: const EdgeInsets.all(8.0),
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Idioma del anfitrión', labelStyle: MyFiltersPage.inputDecoratorLabelStyle),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: listaIdiomasCheckbox,
          ),
        ),
      ),
    );

    Widget bottomBar = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Row(
          children: [
            const Spacer(flex: 1,),
            TextButton(
              onPressed: closeAndResetSearch, // Reset state
              child: const Text('Quitar filtros', style: TextStyle(color: Colors.black,),),
            ),
            const Spacer(flex: 1,),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () async {
                  isDisposed = true;
                  SearchFilters searchFilters = SearchFilters(appState.searchFilters.fechaHoraDesde, appState.searchFilters.fechaHoraHasta,
                      rangoPrecios: rangoPrecios, idiomasElegidos: idiomasElegidos, opcionesReservacionElegidas: opcionesReservacionElegidas,
                      numeroEstacionamientos: numeroEstacionamientos, tipoPropiedadIsSelected: tipoPropiedadIsSelected,
                      tipoEstacionamientoIsSelected: tipoEstacionamientoIsSelected);
                  await appState.setSearchFilters(searchFilters);
                  appState.toggleSearch();
                  navigator.pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      children: [
                        Text('Mostrar $tempNumEstacionamientos'),
                        Text('estacionamiento${(numeroEstacionamientos != 1) ? 's' : ''}'),
                      ]
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1,),
          ],
        ),
      ),
    );

    return SizedBox(
      height: bodyHeight,
      child: Column(
        children: [
          titleBar,
          const Divider(),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                widgetRangoDePrecios,
                widgetTipoDePropiedad,
                widgetTipoDeEstacionamiento,
                widgetOpcionesDeReserva,
                widgetIdiomaPersona,
              ],
            ),
          ),
          const Divider(),
          bottomBar,
        ],
      ),
    );
  }
}
