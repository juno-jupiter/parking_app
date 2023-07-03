import 'package:flutter/material.dart';
import 'package:parking_app/my_search_bar.dart';
import 'package:flutter/services.dart';

class MyFiltersPage extends StatefulWidget {
  const MyFiltersPage({super.key});

  @override
  State<MyFiltersPage> createState() => _MyFiltersPageState();
}

class _MyFiltersPageState extends State<MyFiltersPage> {
  static const double iconSize = 30.0;
  static const List<String> listaIdiomas = ['español', 'inglés', 'portugués', 'francés', 'alemán', 'japonés', 'italiano', 'ruso', 'chino (simplificado)', 'árabe'];
  static const List<String> listaOpcionesReservacion = ['Reservación inmediata', 'Llegada autónoma', 'Entrada sin escalones'];
  static const List<String> listaSubtitulosOpcionesReservacion = [
    'Reserva sin esperar a que responda el anfitrión',
    'Fácil acceso a la propiedad al llegar',
    'Se puede acceder al estacionamientos sin tener que subir o bajar escalones'
  ];
  RangeValues rangoPrecios = const RangeValues(0, 100);
  List<bool> idiomasElegidos = List<bool>.filled(listaIdiomas.length, false);
  List<bool> opcionesReservacionElegidas = List<bool>.filled(listaOpcionesReservacion.length, false);
  int numeroEstacionamientos = 0;
  List<bool> tipoPropiedadIsSelected = [true, false, false];
  List<bool> tipoEstacionamientoIsSelected = [true, false, false, false];
  bool mostrarMasIdiomas = false;

  void selectToggleButtonWithAll(List<bool> selectedList, int index) {
    if (index != 0) {
      selectedList[index] = !selectedList[index];
      int trueCount = 0;
      for (var i = 1; i < selectedList.length; i++) {if (selectedList[i]) {trueCount++;}}
      selectedList[0] = trueCount == (selectedList.length - 1);
    } else if (!selectedList[0]) {selectedList[0] = true;}
    if (selectedList[0]) {for (var i = 1; i < selectedList.length; i++) {selectedList[i] = false;}}
  }

  @override
  Widget build(BuildContext context) {
    TextStyle inputDecoratorLabelStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20,);
    TextStyle boldStyle = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold,);
    TextStyle underlinedStyle = const TextStyle(color: Colors.black, decoration: TextDecoration.underline,);
    Color primaryColor = Theme.of(context).primaryColor;
    BoxConstraints toggleButtonBoxConstrains = const BoxConstraints(minHeight: 40.0,minWidth: 80.0,);
    BorderRadius toggleButtonBorderRadius = const BorderRadius.all(Radius.circular(8));

    double totalHeight = MediaQuery.of(context).size.height;
    double bodyHeight = totalHeight - MySearchBar.height * 2.0;

    List<Widget> listaIdiomasCheckbox = [];
    int idiomasMostrados = mostrarMasIdiomas ? listaIdiomas.length : 3;
    for (var i = 0; i < idiomasMostrados; i++) {
      listaIdiomasCheckbox.add(
          CheckboxListTile(
            title: Text(listaIdiomas[i]),
            value: idiomasElegidos[i],
            onChanged:(bool? value) {setState(() {
              idiomasElegidos[i] = value ?? false;
            });},
          )
      );
    }
    listaIdiomasCheckbox.add(
      TextButton(
          onPressed: (){setState(() {mostrarMasIdiomas = !mostrarMasIdiomas;});},
          child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                children: [
                  Text(mostrarMasIdiomas ? 'Mostrar menos' : 'Mostrar más', style: underlinedStyle,),
                  Icon(mostrarMasIdiomas ? Icons.expand_less : Icons.expand_more, color: Colors.black,),
                ],
              ),
          ),
      )
    );

    List<Widget> listaOpcionesReservacionSwitch = [];
    for (var i = 0; i < listaOpcionesReservacion.length; i++) {
      listaOpcionesReservacionSwitch.add(
        SwitchListTile(
          title: Text(listaOpcionesReservacion[i]),
          subtitle: Text(listaSubtitulosOpcionesReservacion[i]),
          value: opcionesReservacionElegidas[i],
          onChanged: (bool value) {setState(() {opcionesReservacionElegidas[i] = value;});},
        )
      );
    }

    return SizedBox(
      height: bodyHeight,
      child: Column(
        children: [
          SizedBox(
            child: Center(
              child: ListTile(
                leading: IconButton.outlined(
                  icon: const Icon(Icons.close, size: iconSize,),
                  onPressed: () {Navigator.pop(context);},
                ),
                title: const Text('Filtros'),
                titleTextStyle: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Rango de precios', labelStyle: inputDecoratorLabelStyle),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Tipo de propiedad', labelStyle: inputDecoratorLabelStyle),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: ToggleButtons(
                          onPressed: (int index) {setState(() {selectToggleButtonWithAll(tipoPropiedadIsSelected, index);});},
                          borderRadius: toggleButtonBorderRadius,
                          fillColor: primaryColor,
                          selectedColor: Colors.white,
                          textStyle: boldStyle,
                          constraints: toggleButtonBoxConstrains,
                          isSelected: tipoPropiedadIsSelected,
                          children: const [Text('Todo'), Text('Casa'), Text('Edificio'),],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Tipo de estacionamiento', labelStyle: inputDecoratorLabelStyle),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: ToggleButtons(
                          onPressed: (int index) {setState(() {selectToggleButtonWithAll(tipoEstacionamientoIsSelected, index);});},
                          borderRadius: toggleButtonBorderRadius,
                          fillColor: primaryColor,
                          selectedColor: Colors.white,
                          textStyle: boldStyle,
                          constraints: toggleButtonBoxConstrains,
                          isSelected: tipoEstacionamientoIsSelected,
                          children: const [Text('Todo'), Text('Auto'), Text('Moto'), Text('XL'),],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Opciones de reservación', labelStyle: inputDecoratorLabelStyle),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: listaOpcionesReservacionSwitch,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'Idioma del anfitrión', labelStyle: inputDecoratorLabelStyle),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: listaIdiomasCheckbox,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Row(
                children: [
                  const Spacer(flex: 1,),
                  TextButton(
                      onPressed: (){}, // Reset state
                      child: const Text('Quitar filtros', style: TextStyle(color: Colors.black,),),
                  ),
                  const Spacer(flex: 1,),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {Navigator.pop(context);},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            children: [
                              Text('Mostrar $numeroEstacionamientos'),
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
          ),
        ],
      ),
    );
  }
}
