import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
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

    openDateTime () async {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {return const MyDateTimePicker();},
        enableDrag: false,
        clipBehavior: Clip.hardEdge,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
      );
    }

    openFiltersPage () async {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {return filtersPage;},
        enableDrag: true,
        clipBehavior: Clip.hardEdge,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
      );
    }

    return SizedBox(
      height: height,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60),),
        child: ListTile(
          onTap: openDateTime,
          leading: searchBarIcon(
            alignment: Alignment.center,
            icon: Icons.search,
            color: Colors.black38,
            borderColor: Colors.white10,
            onTap: openDateTime,
          ),
          title: Align(
            alignment: Alignment.center,
            child: Text(stringRangoTiempo),
          ),
          trailing: searchBarIcon(
            alignment: Alignment.center,
            icon: Icons.tune,
            color: Colors.black38,
            onTap: openFiltersPage,
          ),
        ),
      ),
    );
  }
}


class MyDateTimePicker extends StatefulWidget {
  const MyDateTimePicker({super.key,});

  @override
  State<MyDateTimePicker> createState() => _MyDateTimePickerState();
}

class _MyDateTimePickerState extends State<MyDateTimePicker> {
  static const double iconSize = 30.0;
  bool initialSearch = true;
  DateTime fechaHoraDesde = DateTime.now();
  DateTime fechaHoraHasta = DateTime.now().add(const Duration(hours: 1));
  DateTime _dateTimeDesde = DateTime.now();
  DateTime _dateTimeHasta = DateTime.now().add(const Duration(hours: 1));
  List<DateTime?> _dates = [];

  bool isDisposed = false;

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
      fechaHoraDesde = appState.fechaHoraDesde;
      fechaHoraHasta = appState.fechaHoraHasta;
      _dateTimeDesde = fechaHoraDesde;
      _dateTimeHasta = fechaHoraHasta;
      _dates = [fechaHoraDesde, fechaHoraHasta];
    }

    double totalHeight = MediaQuery.of(context).size.height;
    double bodyHeight = totalHeight - MySearchBar.height;

    NavigatorState navigator = Navigator.of(context);

    closeAndResetSearch({bool close = true}) async {
      if (close) isDisposed = true;
      await appState.resetSearchFilters();
      if (!close) {
        setState(() {
          initialSearch = true;
        });
      }
      if (close) navigator.pop();
    }

    toggleSearch() async {
      isDisposed = true;
      //Duration tempHoraDesde = Duration(hours: fechaHoraDesde.hour, minutes: fechaHoraDesde.minute);
      //Duration tempHoraHasta = Duration(hours: fechaHoraHasta.hour, minutes: fechaHoraHasta.minute);
      Duration tempHoraDesde = Duration(hours: _dateTimeDesde.hour, minutes: _dateTimeDesde.minute);
      Duration tempHoraHasta = Duration(hours: _dateTimeHasta.hour, minutes: _dateTimeHasta.minute);
      DateTime tempFechaDesde = DateTime(fechaHoraDesde.year, fechaHoraDesde.month, fechaHoraDesde.day);
      DateTime tempFechaHasta = DateTime(fechaHoraHasta.year, fechaHoraHasta.month, fechaHoraHasta.day);
      if (tempHoraDesde.inHours > tempHoraHasta.inHours) tempHoraHasta = tempHoraHasta + const Duration(days: 1);
      if (tempHoraHasta < tempHoraDesde) tempHoraHasta = tempHoraDesde + const Duration(hours: 1);

      if (_dates.isNotEmpty) {
        if (_dates.length == 1) {
          if (_dates.first != null) tempFechaDesde = DateTime(_dates.first!.year, _dates.first!.month, _dates.first!.day);
          if (_dates.first != null) tempFechaHasta = DateTime(_dates.first!.year, _dates.first!.month, _dates.first!.day);
        } else {
          if (_dates.first != null) tempFechaDesde = DateTime(_dates.first!.year, _dates.first!.month, _dates.first!.day);
          if (_dates.last != null) tempFechaHasta = DateTime(_dates.last!.year, _dates.last!.month, _dates.last!.day);
        }
      }

      fechaHoraDesde = tempFechaDesde.add(tempHoraDesde);
      fechaHoraHasta = tempFechaHasta.add(tempHoraHasta);

      SearchFilters searchFilters = SearchFilters(fechaHoraDesde, fechaHoraHasta,
          rangoPrecios: appState.searchFilters.rangoPrecios, idiomasElegidos: appState.searchFilters.idiomasElegidos,
          opcionesReservacionElegidas: appState.searchFilters.opcionesReservacionElegidas,
          numeroEstacionamientos: appState.searchFilters.numeroEstacionamientos, tipoPropiedadIsSelected: appState.searchFilters.tipoPropiedadIsSelected,
          tipoEstacionamientoIsSelected: appState.searchFilters.tipoEstacionamientoIsSelected);
      await appState.setSearchFilters(searchFilters);
      appState.toggleSearch();
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
              onPressed: (){closeAndResetSearch(close: false);}, // Reset state
              child: const Text('Borrar', style: TextStyle(color: Colors.black,),),
            ),
            const Spacer(flex: 1,),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: toggleSearch,
                child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Elegir fechas'),),
              ),
            ),
            const Spacer(flex: 1,),
          ],
        ),
      ),
    );

    final config = CalendarDatePicker2Config(
      calendarType: CalendarDatePicker2Type.range,
      firstDate: DateTime.now(),
    );

    Widget dateRangePicker = CalendarDatePicker2(
      config: config,
      value: _dates,
      onValueChanged: (dates) {
        if (dates.length > 1) {
          if ((dates.first != null) && (dates.last != null)){
            if (!dates.first!.isBefore(dates.last!)) {
              _dates = [dates.first!];
            }
          }
        }
        setState(() {
          _dates = dates;
        });
      }
      );

    print(_dateTimeDesde);
    final Widget timePickerDesde = Center(
      child: Column(
        children: [
          const Text('Hora desde:', style: MyFiltersPage.boldStyle,),
          TimePickerSpinner(
            time: _dateTimeDesde,
            is24HourMode: true,
            isForce2Digits: true,
            onTimeChange: (time) {
              setState(() {
                _dateTimeDesde = time;
              });
            },
          ),
        ],
      ),
    );

    final Widget timePickerHasta = Column(
      children: [
        const Text('Hora hasta:', style: MyFiltersPage.boldStyle,),
        TimePickerSpinner(
          time: _dateTimeHasta,
          is24HourMode: true,
          isForce2Digits: true,
          onTimeChange: (time) {
            setState(() {
              _dateTimeHasta = time;
            });
          },
        ),
      ],
    );

    return SizedBox(
      height: bodyHeight,
      child: Column(
        children: [
          titleBar,
          const Divider(),
          Expanded(
            child: Column(
              children: [
                dateRangePicker,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Spacer(flex: 1,),
                      timePickerDesde,
                      const Spacer(flex: 1,),
                      timePickerHasta,
                      const Spacer(flex: 1,),
                    ],
                  ),
                ),
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
