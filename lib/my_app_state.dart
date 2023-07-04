import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:parking_app/table_entities.dart';

class MyAppState extends ChangeNotifier {
  final Database database;
  MyAppState({required this.database,});

  String moneda = 'CLP';

  Location? selectedLocation;
  Location? openedLocationPage;

  String languageTag = 'es-ES';
  bool isListView = true;
  bool isFirstSearch = true;

  List<int> favLocations = [];

  SearchFilters searchFilters = SearchFilters(DateTime.now(), DateTime.now().add(const Duration(hours: 1)));

  RangeValues rangoPrecios = const RangeValues(0, 100);
  List<bool> idiomasElegidos = List<bool>.filled(SearchFilters.listaIdiomas.length, false);
  List<bool> opcionesReservacionElegidas = List<bool>.filled(SearchFilters.listaOpcionesReservacion.length, false);
  int numeroEstacionamientos = 0;
  List<bool> tipoPropiedadIsSelected = [true, false, false];
  List<bool> tipoEstacionamientoIsSelected = [true, false, false];
  DateTime fechaHoraDesde = DateTime.now();
  DateTime fechaHoraHasta = DateTime.now().add(const Duration(hours: 1));

  Function? reloadCallBack;

  Future<List<Location>> getLocationList({SearchFilters? filters}) async {
    if (filters == null) isFirstSearch = false;
    filters = (filters == null) ? searchFilters : filters;
    return filters.getLocationList(database);
  }

  Future<void> setSearchFilters(SearchFilters filters) async {
    searchFilters = filters;
    rangoPrecios = searchFilters.rangoPrecios;
    idiomasElegidos = searchFilters.idiomasElegidos;
    opcionesReservacionElegidas = searchFilters.opcionesReservacionElegidas;
    numeroEstacionamientos = searchFilters.numeroEstacionamientos;
    tipoPropiedadIsSelected = searchFilters.tipoPropiedadIsSelected;
    tipoEstacionamientoIsSelected = searchFilters.tipoEstacionamientoIsSelected;
    fechaHoraDesde = searchFilters.fechaHoraDesde;
    fechaHoraHasta = searchFilters.fechaHoraHasta;
  }

  Future<void> resetSearchFilters() async {
    searchFilters = SearchFilters(DateTime.now(), DateTime.now().add(const Duration(hours: 1)));
    await setSearchFilters(searchFilters);
    await toggleSearch();
  }

  Future<void> toggleSearch() async {
    reloadCallBack!(this);
    notifyListeners();
  }

  void toggleLocationPage(Location? location) {
    openedLocationPage = (location?.idLocation != openedLocationPage?.idLocation) ? location : null;
    notifyListeners();
  }

  void toggleLocationMarker(Location? location) {
    selectedLocation = (location?.idLocation != selectedLocation?.idLocation) ? location : null;
    notifyListeners();
  }

  void toggleMapView() {
    isListView = false;
    openedLocationPage = null;
    toggleSearch();
  }

  void toggleListView() {
    selectedLocation = null;
    isListView = true;
    openedLocationPage = null;
    toggleSearch();
  }

  Map getAnfitrion(int idAnfitrion) {
    List<Map> anfitriones = [
      {
        'id': 1, 'nombre': 'Municipalidad Ñuñoa', 'rating': 5.0,
        'descripcion': 'Municipalidad de Ñuñoa', 'idiomas': ['español', 'íngles'],
      }
    ];
    return anfitriones.firstWhere((element) => (element['id'] == idAnfitrion), orElse: () => {});
  }

  void toggleFavoriteLocation(Location location) async {
    if (favLocations.contains(location.idLocation)) {favLocations.remove(location.idLocation);} else {favLocations.add(location.idLocation);}
    notifyListeners();
  }

  double getTotalDuration() {return searchFilters.fechaHoraHasta.difference(searchFilters.fechaHoraDesde).inMinutes.toDouble();}

}

class SearchFilters {
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
  List<bool> tipoEstacionamientoIsSelected = [true, false, false];
  DateTime fechaHoraDesde = DateTime.now();
  DateTime fechaHoraHasta = DateTime.now().add(const Duration(hours: 1));

  Map<String, dynamic> toMap() {
    return {
      'rangoPrecios': rangoPrecios, 'idiomasElegidos': idiomasElegidos, 'opcionesReservacionElegidas': opcionesReservacionElegidas,
      'numeroEstacionamientos': numeroEstacionamientos, 'tipoPropiedadIsSelected': tipoPropiedadIsSelected,
      'tipoEstacionamientoIsSelected': tipoEstacionamientoIsSelected, 'fechaHoraDesde': fechaHoraDesde, 'fechaHoraHasta': fechaHoraHasta,
    };
  }

  SearchFilters(this.fechaHoraDesde, this.fechaHoraHasta,{
      this.rangoPrecios = const RangeValues(0, 100),
      this.idiomasElegidos = const [false, false, false, false, false, false, false, false, false, false,],
      this.opcionesReservacionElegidas = const [false, false, false],
      this.numeroEstacionamientos = 0,
      this.tipoPropiedadIsSelected = const [true, false, false],
      this.tipoEstacionamientoIsSelected = const [true, false, false],
  });

  Future<List<Location>> getLocationList(Database database) async {
    String tipoPropiedad = tipoPropiedadIsSelected.first ? '' : (tipoPropiedadIsSelected[1] ? "locations.tipoLocation = 'casa'" : "locations.tipoLocation = 'edificio'");
    String inmediata = opcionesReservacionElegidas[0] ? 'locations.inmediata = 1' : '';
    String autonoma = opcionesReservacionElegidas[1] ? 'locations.autonoma = 1' : '';
    String acceso = opcionesReservacionElegidas[2] ? 'locations.acceso = 1' : '';

    String whereClause = '';
    final List<String> opcionesLocation = [tipoPropiedad, inmediata, autonoma, acceso];
    for (var opcion in opcionesLocation) {
      if (opcion.isNotEmpty) {
        whereClause = whereClause.isNotEmpty ? '$whereClause and $opcion' : 'where $opcion';
      }
    }

    String tipoAuto = tipoEstacionamientoIsSelected[0] ? "estacionamientos.tipoEstacionamiento = 'auto'" : '';
    String tipoMoto = tipoEstacionamientoIsSelected[1] ? "estacionamientos.tipoEstacionamiento = 'moto'" : '';
    String tipoXl = tipoEstacionamientoIsSelected[2] ? "estacionamientos.tipoEstacionamiento = 'xl'" : '';
    String parkWhereClause = '';
    final List<String> opcionesEstacionamiento = [tipoAuto, tipoMoto, tipoXl];
    for (var opcion in opcionesEstacionamiento) {
      if (opcion.isNotEmpty) {parkWhereClause = parkWhereClause.isNotEmpty ? '$parkWhereClause or $opcion' : opcion;}
    }
    if (parkWhereClause.isNotEmpty){
      parkWhereClause = '($parkWhereClause)';
      if (whereClause.isEmpty) {whereClause = 'where $parkWhereClause';}
      else {whereClause = '$whereClause and $parkWhereClause';}
    }

    final List<Map> maps;
    if (whereClause.isNotEmpty){maps = await database.rawQuery('''
    SELECT * FROM locations left JOIN estacionamientos ON locations.idLocation = estacionamientos.locationId $whereClause ORDER BY estacionamientos.idEstacionamiento;
    ''');}
    else {maps = await database.query('locations');}

    final List<Map> mapsEstacionamientos = await database.rawQuery('''
    SELECT * FROM estacionamientos left JOIN locations ON locations.idLocation = estacionamientos.locationId $whereClause ORDER BY estacionamientos.idEstacionamiento;
    ''');
    List<Location> locationList = [];
    Map<int, Location> locationIds = {};
    for (var map in maps) {
      Location newLocation = Location.fromMap(map);
      locationList.add(newLocation);
      locationIds[newLocation.idLocation] = newLocation;
    }
    List<Location> returnList = [];
    for (var map in mapsEstacionamientos) {
      if (locationIds.containsKey(map['locationId'])) {
        Estacionamiento newEstacionamiento = Estacionamiento.fromMap(map);
        locationIds[newEstacionamiento.locationId]?.estacionamientosLista.add(newEstacionamiento);
        if (!returnList.contains(locationIds[newEstacionamiento.locationId])){
          returnList.add(locationIds[newEstacionamiento.locationId]!);
        }
      }
    }
    return returnList;
  }

}