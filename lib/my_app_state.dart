import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class MyAppState extends ChangeNotifier {
  final Database database;
  MyAppState({required this.database,});

  String moneda = 'CLP';

  Location? selectedLocation;
  Location? openedLocationPage;

  String languageTag = 'es-ES';
  bool isListView = true;

  List<int> favLocations = [];

  Map searchFilters = {
    'fecha_hora_desde': DateTime.now(),
    'fecha_hora_hasta': DateTime.now().add(const Duration(hours: 1)),
    'precio_minimo': 100.0, 'precio_maximo': 10000.0,
    'tipo_location': ['casa', 'edificio'],
    'idiomas': [], 'caracteristicas_location': [], 'caracteristicas_estacionamiento': []
  };

  void toggleLocationPage(Location? location) {
    openedLocationPage = (location?.id != openedLocationPage?.id) ? location : null;
    notifyListeners();
  }

  void toggleLocationMarker(Location? location) {
    selectedLocation = (location?.id != selectedLocation?.id) ? location : null;
    notifyListeners();
  }

  void toggleMapView() {
    isListView = false;
    notifyListeners();
  }

  void toggleListView() {
    selectedLocation = null;
    isListView = true;
    notifyListeners();
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
    if (favLocations.contains(location.id)) {favLocations.remove(location.id);} else {favLocations.add(location.id);}
    notifyListeners();

  }

  double getTotalDuration() {return searchFilters['fecha_hora_hasta'].difference(searchFilters['fecha_hora_desde']).inMinutes.toDouble();}

}

class Location {
  final int id;
  final double lat;
  final double lng;
  final String nombre;
  final double rating;
  final String calle;
  final String numero;
  final String comuna;
  final String tipo;
  final int anfitrionId;
  final String descripcion;
  double precioTotal = 0.0;
  List<Estacionamiento> estacionamientosLista = [];

  Location(this.id, this.lat, this.lng, this.nombre, this.rating, this.calle, this.numero, this.comuna, this.tipo, this.anfitrionId, this.descripcion,);
  // The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id, 'lat': lat, 'lng': lng, 'nombre': nombre, 'rating': rating,
      'calle': calle, 'numero': numero, 'comuna': comuna, 'tipo': tipo,
      'anfitrionId': anfitrionId, 'descripcion': descripcion,
    };
  }

  Future<void> cargarEstacionamientos(Database database) async {estacionamientosLista = await getEstacionamientos(database, id);}
  static Future<List<Estacionamiento>> getEstacionamientos(Database database, int locationId) async {
    final List<Map> maps = await database.query('estacionamientos', where: 'locationId = ?', whereArgs: [locationId]);
    List<Estacionamiento> estacionamientoList = [];
    for (var map in maps) {estacionamientoList.add(Estacionamiento.fromMap(map));}
    return estacionamientoList;
  }

  void recalculateTotalCost(double durationMinutes) {
    double precioMenor = double.maxFinite;
    for (var parking in estacionamientosLista) {
      parking.precioTotal = parking.getTotalCost(durationMinutes);
      if (parking.precioTotal < precioMenor) {precioMenor = parking.precioTotal;}
    }
    precioTotal = precioMenor;
  }

  Future<void> insert(Database database) async {await database.insert('locations', toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);}
  Future<void> delete(Database database) async {await database.delete('locations', where: 'id = ?', whereArgs: [id],);}

  static Location fromMap(Map map) {
    return Location(int.parse(map['id'].toString()), double.parse(map['lat'].toString()),
      double.parse(map['lng'].toString()), map['nombre'], double.parse(map['rating'].toString()),
      map['calle'], map['numero'], map['comuna'], map['tipo'], int.parse(map['anfitrionId'].toString()), map['descripcion'],);
  }

  static Future<Location?> getLocation(Database database, int locationId) async {
    final List<Map> maps = await database.query('locations', where: 'id = ?', whereArgs: [locationId]);
    if (maps.isNotEmpty) {
      Location newLocation = Location.fromMap(maps.first);
      await newLocation.cargarEstacionamientos(database);
    }
    return null;
  }

  static Future<List<Location>> getLocationList(Database database) async {
    final List<Map> maps = await database.query('locations');
    List<Location> locationList = [];
    for (var map in maps) {
      Location newLocation = Location.fromMap(map);
      await newLocation.cargarEstacionamientos(database);
      locationList.add(newLocation);
    }
    return locationList;
  }

  static Future<void> createTable(database) async {
    return database.execute('''
    create table locations(
     id integer primary key, lat real, lng real, nombre text, rating real,
     calle text, numero text, comuna text, tipo text, anfitrionId integer, descripcion text
    )
    ''',);
  }

}

class Estacionamiento {
  final int id;
  final int locationId;
  final String nombre;
  final double precio;
  final double rating;
  final String descripcion;
  double precioTotal = 0.0;

  Estacionamiento(this.id, this.locationId, this.nombre, this.precio, this.rating, this.descripcion,);
  double getTotalCost(double durationMinutes) {return precio * (durationMinutes / 60.0);}
  Map<String, dynamic> toMap() {return {'id': id, 'locationId': locationId,'nombre': nombre, 'precio': precio, 'rating': rating, 'descripcion': descripcion,};}
  Future<void> insert(Database database) async {await database.insert('estacionamientos', toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);}
  Future<void> delete(Database database) async {await database.delete('estacionamientos', where: 'id = ?', whereArgs: [id],);}

  static Estacionamiento fromMap(Map map) {
    return Estacionamiento(
      int.parse(map['id'].toString()), int.parse(map['locationId'].toString()), map['nombre'],
      double.parse(map['precio'].toString()), double.parse(map['rating'].toString()), map['descripcion'],
    );
  }

  static Future<Estacionamiento?> getEstacionamiento(Database database, int estacionamientoId) async {
    final List<Map> maps = await database.query('estacionamientos', where: 'id = ?', whereArgs: [estacionamientoId]);
    if (maps.isNotEmpty) {return Estacionamiento.fromMap(maps.first);}
    return null;
  }

  static Future<List<Estacionamiento>> getEstacionamientoList(Database database) async {
    final List<Map> maps = await database.query('estacionamientos');
    List<Estacionamiento> estacionamientoList = [];
    for (var map in maps) {estacionamientoList.add(Estacionamiento.fromMap(map));}
    return estacionamientoList;
  }

  static Future<void> createTable(database) async {
    return database.execute('create table estacionamientos(id integer primary key, locationId integer, nombre text, precio real, rating real, descripcion text)',);
  }
}