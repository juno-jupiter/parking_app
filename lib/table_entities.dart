import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'my_app_state.dart';

getTotalDuration(DateTime fechaHoraHasta, DateTime fechaHoraDesde) {return fechaHoraHasta.difference(fechaHoraDesde).inMinutes.toDouble();}

String formatDate(DateTime dateTime, String languageTag) {
  String dia = DateFormat('EEEE', languageTag).format(dateTime);
  String numDia = dateTime.day.toString().padLeft(2, '0');
  String diaMes = '$numDia ${DateFormat('MMMM', languageTag).format(dateTime).substring(0, 3)}';
  return '${dia.substring(0, 3)}., $diaMes.';
}

String getTimeRangeString(MyAppState appState, {splitTimeDay=true}) {
  DateTime fechaHoraDesde = appState.searchFilters.fechaHoraDesde;
  DateTime fechaHoraHasta = appState.searchFilters.fechaHoraHasta;
  String strHoraDesde = DateFormat('jm', appState.languageTag).format(fechaHoraDesde);
  String strDiaDesde = formatDate(fechaHoraDesde, appState.languageTag);
  String strHoraHasta = DateFormat('jm', appState.languageTag).format(fechaHoraHasta);
  String strDiaHasta = formatDate(fechaHoraHasta, appState.languageTag);
  String splitter = splitTimeDay ? '\n' : ' ';
  if (fechaHoraDesde.day != fechaHoraHasta.day) {
    return '$strDiaDesde - $strDiaHasta$splitter$strHoraDesde - $strHoraHasta';
  }
  return '$strDiaDesde$splitter$strHoraDesde - $strHoraHasta';
}

class Location {
  static const List<String> listaOpcionesReservacion = ['Reserva inmediata', 'Llegada autónoma', 'Acceso sin escaleras'];
  static const List<String> listaSubtitulosOpcionesReservacion = [
    'Reserva sin esperar a que responda el anfitrión',
    'Fácil acceso a la propiedad al llegar',
    'Se puede acceder al estacionamientos sin tener que subir o bajar escaleras'
  ];

  final int idLocation;
  final double lat;
  final double lng;
  final String tituloLocation;
  final double ratingLocation;
  final String calle;
  final String numero;
  final String comuna;
  final String tipoLocation;
  final int anfitrionId;
  final String descripcionLocation;
  final int inmediata;
  final int autonoma;
  final int acceso;
  Anfitrion? anfitrion;
  double precioMinimo = 0.0;
  List<Estacionamiento> estacionamientosLista = [];

  Location(this.idLocation, this.lat, this.lng, this.tituloLocation, this.ratingLocation, this.calle, this.numero,
      this.comuna, this.tipoLocation, this.anfitrionId, this.descripcionLocation, this.inmediata, this.autonoma, this.acceso);
  // The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'idLocation': idLocation, 'lat': lat, 'lng': lng, 'nombreLocation': tituloLocation, 'ratingLocation': ratingLocation,
      'calle': calle, 'numero': numero, 'comuna': comuna, 'tipoLocation': tipoLocation,
      'anfitrionId': anfitrionId, 'descripcionLocation': descripcionLocation, 'inmediata': inmediata, 'autonoma': autonoma, 'acceso': acceso,
    };
  }

  void recalculateTotalCost(double durationMinutes) {
    double precioMenor = double.maxFinite;
    for (var parking in estacionamientosLista) {
      parking.precioTotal = parking.getTotalCost(durationMinutes);
      if (parking.precioTotal < precioMenor) {precioMenor = parking.precioTotal;}
    }
    precioMinimo = precioMenor;
  }

  Future<void> insert(Database database) async {await database.insert('locations', toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);}
  Future<void> delete(Database database) async {await database.delete('locations', where: 'idLocation = ?', whereArgs: [idLocation],);}

  static Location fromMap(Map map) {
    return Location(
        int.parse(map['idLocation'].toString()), double.parse(map['lat'].toString()),
        double.parse(map['lng'].toString()), map['nombreLocation'], double.parse(map['ratingLocation'].toString()),
        map['calle'], map['numero'], map['comuna'], map['tipoLocation'], int.parse(map['anfitrionId'].toString()), map['descripcionLocation'],
        int.parse(map['inmediata'].toString()), int.parse(map['autonoma'].toString()), int.parse(map['acceso'].toString())
    );
  }

  static Future<Location?> getLocation(Database database, int locationId) async {
    final List<Map> maps = await database.query('locations', where: 'idLocation = ?', whereArgs: [locationId]);
    if (maps.isNotEmpty) {
      Location newLocation = Location.fromMap(maps.first);
      final List<Map> mapsEstacionamientos = await database.rawQuery('''
      SELECT * FROM estacionamientos LEFT JOIN locations ON estacionamientos.locationId = ? ORDER BY estacionamientos.idEstacionamiento;
      ''', [locationId]);
      for (var map in mapsEstacionamientos) {
        Estacionamiento newEstacionamiento = Estacionamiento.fromMap(map);
        newLocation.estacionamientosLista.add(newEstacionamiento);
      }
      return newLocation;
    }
    return null;
  }

  static Future<List<Location>> getLocationList(Database database) async {
    final List<Map> maps = await database.query('locations');
    final List<Map> mapsEstacionamientos = await database.rawQuery('''
    SELECT * FROM estacionamientos left JOIN locations ON locations.idLocation = estacionamientos.locationId ORDER BY estacionamientos.idEstacionamiento;
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

  static Future<void> createTable(database) async {
    return database.execute('''
    create table locations(
     idLocation integer primary key, lat real, lng real, nombreLocation text, ratingLocation real,
     calle text, numero text, comuna text, tipoLocation text, anfitrionId integer, descripcionLocation text,
     inmediata integer, autonoma integer, acceso integer
    )
    ''',);
  }

}

class Estacionamiento {
  final int idEstacionamiento;
  final int locationId;
  final String nombreEstacionamiento;
  final double precio;
  final double ratingEstacionamiento;
  final String descripcionEstacionamiento;
  final String tipoEstacionamiento;
  double precioTotal = 0.0;

  Estacionamiento(this.idEstacionamiento, this.locationId, this.nombreEstacionamiento, this.precio, this.ratingEstacionamiento, this.descripcionEstacionamiento, this.tipoEstacionamiento,);
  double getTotalCost(double durationMinutes) {return precio * (durationMinutes / 60.0);}
  Map<String, dynamic> toMap() {
    return {'idEstacionamiento': idEstacionamiento, 'locationId': locationId,'nombreEstacionamiento': nombreEstacionamiento, 'precio': precio,
      'ratingEstacionamiento': ratingEstacionamiento, 'descripcionEstacionamiento': descripcionEstacionamiento, 'tipoEstacionamiento': tipoEstacionamiento,};
  }
  Future<void> insert(Database database) async {await database.insert('estacionamientos', toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);}
  Future<void> delete(Database database) async {await database.delete('estacionamientos', where: 'idEstacionamiento = ?', whereArgs: [idEstacionamiento],);}

  static Estacionamiento fromMap(Map map) {
    return Estacionamiento(
      int.parse(map['idEstacionamiento'].toString()), int.parse(map['locationId'].toString()), map['nombreEstacionamiento'],
      double.parse(map['precio'].toString()), double.parse(map['ratingEstacionamiento'].toString()), map['descripcionEstacionamiento'],
      map['tipoEstacionamiento'],
    );
  }

  static Future<Estacionamiento?> getEstacionamiento(Database database, int estacionamientoId) async {
    final List<Map> maps = await database.query('estacionamientos', where: 'idEstacionamiento = ?', whereArgs: [estacionamientoId]);
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
    return database.execute('''
    create table estacionamientos(idEstacionamiento integer primary key, locationId integer, nombreEstacionamiento text,
    precio real, ratingEstacionamiento real, descripcionEstacionamiento text, tipoEstacionamiento text)
    ''',);
  }
}

class Anfitrion {
  final int idAnfitrion;
  final double ratingAnfitrion;
  final String nombreAnfitrion;
  final String descripcionAnfitrion;
  List<IdiomaPersona> idiomas = [];

  Anfitrion(this.idAnfitrion, this.ratingAnfitrion, this.nombreAnfitrion, this.descripcionAnfitrion, );

  Map<String, dynamic> toMap() {
    return {'idAnfitrion': idAnfitrion, 'ratingAnfitrion': ratingAnfitrion,'nombreAnfitrion': nombreAnfitrion, 'descripcionAnfitrion': descripcionAnfitrion,
    };
  }
  Future<void> insert(Database database) async {await database.insert('anfitriones', toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);}
  Future<void> delete(Database database) async {await database.delete('anfitriones', where: 'idAnfitrion = ?', whereArgs: [idAnfitrion],);}

  static Anfitrion fromMap(Map map) {
    return Anfitrion(
      int.parse(map['idAnfitrion'].toString()), double.parse(map['ratingAnfitrion'].toString()), map['nombreAnfitrion'],
      map['descripcionAnfitrion'],);
  }

  static Future<Anfitrion?> getAnfitrion(Database database, int anfitrionId) async {
    final List<Map> maps = await database.query('anfitriones', where: 'idAnfitrion = ?', whereArgs: [anfitrionId]);
    if (maps.isNotEmpty) {return Anfitrion.fromMap(maps.first);}
    return null;
  }

  static Future<List<Anfitrion>> getAnfitrionList(Database database) async {
    final List<Map> maps = await database.query('anfitriones');
    List<Anfitrion> anfitrionesList = [];
    for (var map in maps) {anfitrionesList.add(Anfitrion.fromMap(map));}
    return anfitrionesList;
  }

  static Future<void> createTable(database) async {
    return database.execute('''
    create table anfitriones(idAnfitrion integer primary key, ratingAnfitrion real, nombreAnfitrion text, descripcionAnfitrion text)
    ''',);
  }
}

class IdiomaPersona {
  static const List<String> listaIdiomas = ['español', 'inglés', 'portugués', 'francés', 'alemán', 'japonés', 'italiano', 'ruso', 'chino (simplificado)', 'árabe'];
  final int idIdioma;
  final int personaId;
  final int esAnfitrion;
  final String nombreIdioma;

  IdiomaPersona(this.idIdioma, this.personaId, this.esAnfitrion, this.nombreIdioma,);

  Map<String, dynamic> toMap() {
    return {'idIdioma': idIdioma, 'personaId': personaId, 'esAnfitrion': esAnfitrion,'nombreIdioma': nombreIdioma,
    };
  }
  Future<void> insert(Database database) async {await database.insert('idiomas', toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);}
  Future<void> delete(Database database) async {await database.delete('idiomas', where: 'idIdioma = ?', whereArgs: [idIdioma],);}

  static IdiomaPersona fromMap(Map map) {
    return IdiomaPersona(
      int.parse(map['idIdioma'].toString()), int.parse(map['personaId'].toString()), map['esAnfitrion'],
      map['nombreIdioma'],);
  }

  static Future<IdiomaPersona?> getIdiomaPersona(Database database, int idiomaId) async {
    final List<Map> maps = await database.query('idiomas', where: 'idIdioma = ?', whereArgs: [idiomaId]);
    if (maps.isNotEmpty) {return IdiomaPersona.fromMap(maps.first);}
    return null;
  }

  static Future<List<IdiomaPersona>> getIdiomaPersonaList(Database database) async {
    final List<Map> maps = await database.query('idiomas');
    List<IdiomaPersona> idiomasList = [];
    for (var map in maps) {idiomasList.add(IdiomaPersona.fromMap(map));}
    return idiomasList;
  }

  static Future<void> createTable(database) async {
    return database.execute('''
    create table idiomas(idIdioma integer primary key, personaId integer, esAnfitrion integer, nombreIdioma text)
    ''',);
  }
}

class Favorito {
  final int idFavorito;
  final int coleccionFavoritosId;
  final int locationId;
  Favorito(this.idFavorito, this.coleccionFavoritosId, this.locationId);

  Map<String, dynamic> toMap() {return {'idFavorito': idFavorito, 'coleccionFavoritosId': coleccionFavoritosId,'locationId': locationId, };}
  Future<int> insert(Database database) async {
    if (idFavorito < 0) {
      // Self increment
      final List<Map> maps = await database.query('favoritos', where: 'idFavorito=(SELECT max(idFavorito) from favoritos)');
      int lastId = 0;
      if (maps.isNotEmpty) lastId = int.parse(maps.last['idFavorito'].toString());
      return Favorito(lastId + 1, coleccionFavoritosId, locationId).insert(database);
    }
    await database.insert('favoritos', toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);
    return idFavorito;
  }
  Future<void> delete(Database database) async {await database.delete('favoritos', where: 'idFavorito = ?', whereArgs: [idFavorito],);}

  static Favorito fromMap(Map map) {
    return Favorito(int.parse(map['idFavorito'].toString()), int.parse(map['coleccionFavoritosId'].toString()), int.parse(map['locationId'].toString()),);
  }

  static Future<Favorito?> getFavorito(Database database, int idFavorito) async {
    final List<Map> maps = await database.query('favoritos', where: 'idFavorito = ?', whereArgs: [idFavorito]);
    if (maps.isNotEmpty) {return Favorito.fromMap(maps.first);}
    return null;
  }

  static Future<List<Favorito>> getFavoritosList(Database database) async {
    final List<Map> maps = await database.query('favoritos');
    List<Favorito> favoritosList = [];
    for (var map in maps) {favoritosList.add(Favorito.fromMap(map));}
    return favoritosList;
  }

  static Future<void> createTable(database) async {
    return database.execute('''
    create table favoritos(idFavorito integer primary key, coleccionFavoritosId integer, locationId integer)
    ''',);
  }
}

class ColeccionFavoritos {
  final int idColeccionFavoritos;
  final int perfilId;
  final String nombreColeccionFavoritos;
  List<Favorito> favoritosLista = [];

  ColeccionFavoritos(this.idColeccionFavoritos, this.perfilId, this.nombreColeccionFavoritos,);

  Map<String, dynamic> toMap() {
    return {'idColeccionFavoritos': idColeccionFavoritos, 'perfilId': perfilId, 'nombreColeccionFavoritos': nombreColeccionFavoritos,};
  }
  Future<int> insert(Database database) async {
    if (idColeccionFavoritos < 0) {
      // Self increment
      final List<Map> maps = await database.query('colecciones_favoritos', where: 'idColeccionFavoritos=(SELECT max(idColeccionFavoritos) from colecciones_favoritos)',);
      int lastId = 0;
      if (maps.isNotEmpty) lastId = int.parse(maps.last['idColeccionFavoritos'].toString());
      return ColeccionFavoritos(lastId + 1, perfilId, nombreColeccionFavoritos).insert(database);
    }
    await database.insert('colecciones_favoritos', toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);
    return idColeccionFavoritos;
  }
  Future<void> delete(Database database) async {await database.delete('colecciones_favoritos', where: 'idColeccionFavoritos = ?', whereArgs: [idColeccionFavoritos],);}

  static ColeccionFavoritos fromMap(Map map) {
    return ColeccionFavoritos(int.parse(map['idColeccionFavoritos'].toString()), int.parse(map['perfilId'].toString()), map['nombreColeccionFavoritos'],);
  }

  Future<List<Favorito>> getFavoritos(Database database) async {
    List<Favorito> nuevoListado = [];
    final List<Map> maps = await database.query('favoritos', where: 'coleccionFavoritosId = ?', whereArgs: [idColeccionFavoritos]);
    for (var map in maps) {
      nuevoListado.add(Favorito.fromMap(map));
    }
    return nuevoListado;
  }

  static Future<ColeccionFavoritos?> getColeccionFavoritos(Database database, int idColeccionFavoritos) async {
    final List<Map> maps = await database.query('colecciones_favoritos', where: 'idColeccionFavoritos = ?', whereArgs: [idColeccionFavoritos]);
    if (maps.isNotEmpty) {return ColeccionFavoritos.fromMap(maps.first);}
    return null;
  }

  static Future<List<ColeccionFavoritos>> getColeccionFavoritosList(Database database) async {
    final List<Map> maps = await database.query('colecciones_favoritos');
    List<ColeccionFavoritos> coleccionesFavoritosList = [];
    for (var map in maps) {coleccionesFavoritosList.add(ColeccionFavoritos.fromMap(map));}
    return coleccionesFavoritosList;
  }

  static Future<void> createTable(database) async {
    return database.execute('''
    create table colecciones_favoritos(idColeccionFavoritos integer primary key, perfilId integer, nombreColeccionFavoritos text)
    ''',);
  }
}

class Perfil {
  static const List<String> listaMonedas = ['CLP', 'USD',];
  final int idPerfil;
  final String moneda;
  final String numeroTelefonico;
  final int ultimaColeccionGuardadaId;
  List<ColeccionFavoritos> listadoColeccionesFavoritos = [];

  Perfil(this.idPerfil, this.moneda, this.numeroTelefonico, this.ultimaColeccionGuardadaId);

  Map<String, dynamic> toMap() {
    return {'idPerfil': idPerfil, 'moneda': moneda, 'numeroTelefonico': numeroTelefonico, 'ultimaColeccionGuardadaId': ultimaColeccionGuardadaId,};
  }
  Future<void> insert(Database database) async {await database.insert('perfiles', toMap(), conflictAlgorithm: ConflictAlgorithm.replace,);}
  Future<void> delete(Database database) async {await database.delete('perfiles', where: 'idPerfil = ?', whereArgs: [idPerfil],);}

  Future<List<ColeccionFavoritos>> getColeccionesFavoritos(Database database) async {
    List<ColeccionFavoritos> nuevoListado = [];
    final List<Map> maps = await database.query('colecciones_favoritos', where: 'perfilId = ?', whereArgs: [idPerfil]);
    for (var map in maps) {
      ColeccionFavoritos coleccion = ColeccionFavoritos.fromMap(map);
      coleccion.favoritosLista = await coleccion.getFavoritos(database);
      nuevoListado.add(coleccion);
    }
    return nuevoListado;
  }

  int tieneLocationFavorito(Location location) {
    int i = 0;
    for (var coleccion in listadoColeccionesFavoritos) {
      if (coleccion.favoritosLista.any((item) => item.locationId == location.idLocation)) return i;
      i++;
    }
    return -1;
  }

  static Perfil fromMap(Map map) {
    return Perfil(int.parse(map['idPerfil'].toString()), map['moneda'], map['numeroTelefonico'], int.parse(map['ultimaColeccionGuardadaId'].toString()),);
  }

  static Future<Perfil?> getPerfil(Database database, int idPerfil) async {
    final List<Map> maps = await database.query('perfiles', where: 'idPerfil = ?', whereArgs: [idPerfil]);
    if (maps.isNotEmpty) {return Perfil.fromMap(maps.first);}
    return null;
  }

  static Future<List<Perfil>> getPerfilList(Database database) async {
    final List<Map> maps = await database.query('perfiles');
    List<Perfil> perfilesList = [];
    for (var map in maps) {perfilesList.add(Perfil.fromMap(map));}
    return perfilesList;
  }

  static Future<void> createTable(database) async {
    return database.execute('''
    create table perfiles(idPerfil integer primary key, moneda text, numeroTelefonico text, ultimaColeccionGuardadaId integer)
    ''',);
  }
}
