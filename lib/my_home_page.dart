import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'my_map_page.dart';
import 'my_listview_page.dart';
import 'my_favorites_page.dart';
import 'my_scheduled_page.dart';
import 'my_messages_page.dart';
import 'my_account_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  void initState(){
    super.initState();
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    Widget page;  // Elige ventana
    String appBarTitle = '';
    switch (selectedIndex) {
      case 0:
        page = appState.isListView ? const MyListViewPage() : const MyMapPage();
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

    return Scaffold(
      appBar: selectedAppBar,
      body: Center(
        child: page,
      ),
      bottomNavigationBar: myBottomNavigationBar,
    );
  }
}
