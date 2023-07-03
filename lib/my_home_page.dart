import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_map_page.dart';
import 'package:parking_app/my_listview_page.dart';
import 'package:parking_app/my_favorites_page.dart';
import 'package:parking_app/my_scheduled_page.dart';
import 'package:parking_app/my_messages_page.dart';
import 'package:parking_app/my_account_page.dart';

class MyHomePage extends StatefulWidget {
  final Database database;
  const MyHomePage(this.database, {super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Location> locationList = [];
  var selectedIndex = 0;
  MyAppState? appState;

  @override
  void initState(){
    super.initState();
    initializeDateFormatting();
    Future.delayed(Duration.zero, () async {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        List<Location> newLocs = await appState!.getLocationList();
        setState(() {locationList = newLocs;});
        appState?.reloadCallBack = reloadSearch;
      });
    });

  }

  Future<void> reloadSearch(MyAppState newAppState) async {
    appState = newAppState;
    List<Location> foundList = await appState!.getLocationList();
    setState(() {locationList = foundList;});
  }

  @override
  Widget build(BuildContext context) {
    appState = Provider.of<MyAppState>(context, listen: true);
    if (appState != null) appState?.reloadCallBack = reloadSearch;
    Widget page;  // Elige ventana
    String appBarTitle = '';

    switch (selectedIndex) {
      case 0:
        page = (appState!.isListView) ? MyListViewPage(locationList) : MyMapPage(locationList);
        break;
      case 1:
        page = const MyFavoritesPage();
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
        appBarTitle = 'Perfil';
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    AppBar? selectedAppBar = (selectedIndex > 0) ? AppBar(title: Text(appBarTitle),) : null;

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
          label: 'Perfil',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: (value) {
        setState(() {
          selectedIndex = value;
        });
      },
    );

    Scaffold mainScaffold = Scaffold(appBar: selectedAppBar, body: Center(child: page,), bottomNavigationBar: myBottomNavigationBar,);
    return mainScaffold;
  }
}
