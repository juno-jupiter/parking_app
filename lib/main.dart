import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Parking App',
        theme: ThemeData(primarySwatch: Colors.blue,),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var openedLocationCard = false;

  void toggleLocationCard() {
    openedLocationCard = !openedLocationCard;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    Widget? page;  // Elige ventana
    String appBarTitle = '';
    switch (selectedIndex) {
      case 0:
        List<Widget> stackChildren = [];
        var mapPage = FlutterMap(
          options: MapOptions(
            center: const LatLng(-33.455941054704866, -70.59368311749424),
            zoom: 17.0,
            maxZoom: 18.0,
            minZoom: 12.0,
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          nonRotatedChildren: [
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                ),
              ],
            ),
          ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                    point: const LatLng(-33.455941054704866, -70.59368311749424),
                    width: 120,
                    height: 80,
                    builder: (context) => Stack(
                        children: <Widget>[
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: () => appState.toggleLocationCard(),
                            child: const Text('\$1000/h', style: TextStyle(color: Colors.black),),
                          ),
                        ]
                    )
                ),
              ],
            ),
          ],
        );
        stackChildren.add(mapPage);

        var searchBar = Column(
          children: [
            const SizedBox(height: 40,),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SearchBar(
                  onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const FilterPage()));
                    },
                  leading: const Icon(Icons.search),
                  hintText: 'Busca aquí',
                ),
              ),
            ),
          ],
        );
        stackChildren.add(searchBar);

        if (appState.openedLocationCard) {
          stackChildren.add(const LocationCard());
        }

        page = Stack(children: stackChildren,);
        break;
      case 1:
        page = const MyFavoritePage();
        appBarTitle = 'Favoritos';
        break;
      case 2:
        page = const MyScheduledPage();
        appBarTitle = 'Reservas';
        break;
      case 3:
        page = const MyMessagesPage();
        appBarTitle = 'Mensajes';
        break;
      case 4:
        page = const MyAccountPage();
        appBarTitle = 'Cuenta';
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    AppBar? selectedAppBar = AppBar(
      title: Text(appBarTitle),
    );
    if (selectedIndex == 0) {
      selectedAppBar = null;
    }

    BottomNavigationBar myBottomNavigationBar = BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: Colors.black,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined,),
          label: 'Explora',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outlined,),
          label: 'Favoritos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule_outlined,),
          label: 'Reservas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outlined,),
          label: 'Mensajes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined,),
          label: 'Cuenta',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: (value) {
        setState(() {
          selectedIndex = value;
        });
      },
    );

    return Scaffold(
      appBar: selectedAppBar,
      body: Center(
        child: page,
      ),
      bottomNavigationBar: myBottomNavigationBar,
    );
  }
}

class MyFavoritePage extends StatelessWidget {
  const MyFavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Favoritos');
  }

}

class MyScheduledPage extends StatelessWidget {
  const MyScheduledPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Reservas');
  }

}

class MyMessagesPage extends StatelessWidget {
  const MyMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Mensajes');
  }

}

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Cuenta');
  }

}

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool isFav = false;
  double rating = 3.5;
  double precio = 1000;
  String nombre = 'Plaza Ñuñoa';
  String imageFile = 'assets/nunoa.jpg';
  String tiempo = 'Precio para 1 hora';

  @override
  Widget build(BuildContext context) {
    dynamic currentTime = DateFormat.jm().format(DateTime.now());
    dynamic nextTime = DateFormat.jm().format(DateTime.now().add(const Duration(hours: 1,)));

    var currentFavIcon = Icons.favorite_outline;
    if (isFav) {
      currentFavIcon = Icons.favorite;
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(nombre)),
            Align(alignment: Alignment.centerLeft, child: Text(tiempo, style: const TextStyle(fontSize: 10))),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () => setState(() => isFav = !isFav),
              icon: Icon(currentFavIcon),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Image(image: AssetImage(imageFile)),
          const SizedBox(height: 10,),
          ListTile(
            title: Column(
              children: [Align(alignment: Alignment.centerLeft, child: Text(nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, ), )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StarRating(
                    rating: rating,
                    onRatingChanged: (rating) => setState(() => this.rating = rating),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: Text('$tiempo:', style: const TextStyle(fontWeight: FontWeight.bold),),),
                Align(alignment: Alignment.centerLeft, child: Text('CL \$$precio',),),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          ListTile(
            title: Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        const Align(alignment: Alignment.centerLeft, child: Text('Desde', style: TextStyle(fontWeight: FontWeight.bold),),),
                        Align(alignment: Alignment.centerLeft, child: Text('$currentTime',),),
                      ],
                    ),
                    const SizedBox(width: 20,),
                    Column(
                      children: [
                        const Align(alignment: Alignment.centerLeft, child: Text('Hasta', style: TextStyle(fontWeight: FontWeight.bold),),),
                        Align(alignment: Alignment.centerLeft, child: Text('$nextTime',),),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5,),
                const Align(alignment: Alignment.centerLeft, child: Text('Características', style: TextStyle(fontWeight: FontWeight.bold),),),
                const Align(alignment: Alignment.centerLeft, child: Text('Casa',),),
              ],
            ),
          ),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }

}

class LocationCard extends StatefulWidget {
  const LocationCard({super.key});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  bool isFav = false;
  double rating = 3.5;
  double precio = 1000;
  String nombre = 'Plaza Ñuñoa';
  String imageFile = 'assets/nunoa.jpg';
  String tiempo = 'Precio para 1 hora';

  @override
  Widget build(BuildContext context) {

    var currentFavIcon = Icons.favorite_outline;
    if (isFav) {
      currentFavIcon = Icons.favorite;
    }

    return Column(
        children: <Widget>[
          const Expanded(child:Center(child:null),),
          Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Theme.of(context).primaryColor.withAlpha(30),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const LocationPage()));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Image(image: AssetImage(imageFile)),
                    title: Text(nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, ), ),
                    subtitle: Column(
                      children: [
                        StarRating(
                          rating: rating,
                          onRatingChanged: (rating) => setState(() => this.rating = rating),
                        ),
                        Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text('$tiempo:', style: const TextStyle(fontWeight: FontWeight.bold),),
                              ),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('CL \$$precio', style: const TextStyle(fontSize: 20),),
                              ),
                            ]
                        )
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => setState(() => isFav = !isFav),
                      icon: Icon(currentFavIcon),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]
    );
  }
}

typedef RatingChangeCallback = void Function(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color? color;

  const StarRating({super.key, this.starCount = 5, this.rating = .0, required this.onRatingChanged, this.color,});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = Icon(
        Icons.star_border,
        color: Theme.of(context).primaryColor,
      );
    }
    else if (index > rating - 1 && index < rating) {
      icon = Icon(
        Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
      );
    } else {
      icon = Icon(
        Icons.star,
        color: color ?? Theme.of(context).primaryColor,
      );
    }
    return InkResponse(
      onTap: () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(starCount, (index) => buildStar(context, index)));
  }
}

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Filtros'),
        actions: const [
          TextButton(onPressed: null, child: Text('Quitar filtros'))
        ],
        ),
      body: Column(
        children: [
          const Column(
              children: [
                SizedBox(height: 10,),
              ]
          ),
          const Expanded(child: Center(child: null,)),
          Center(
            child: ElevatedButton(
                onPressed: () {Navigator.pop(context);},
                child: const Text('Ver resultados')),
          ),
        ],
      ),
    );
  }
}
