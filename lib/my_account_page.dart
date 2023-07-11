import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/table_entities.dart';
import 'package:parking_app/my_app_state.dart';
import 'package:parking_app/my_filters_page.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context, listen: true);

    Widget tarjetaPerfil = Container(
        alignment: Alignment.center,
        width: double.infinity, height: 200,
        child: const Column(
          children: [
            Spacer(flex: 2,),
            Icon(Icons.account_circle, size: 80,),
            Text('Perfil', style: MyFiltersPage.inputDecoratorLabelStyle,),
            Spacer(flex: 2,),
          ],
        )
    );

    List<Widget> listaConfiguracion = [
      const Padding(
          padding: EdgeInsets.all(4.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: ListTile(title: Text('Configuración', style: MyFiltersPage.inputDecoratorLabelStyle),),
              )
          )
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(leading: Icon(Icons.account_circle_outlined), title: Text('Información personal'), trailing: Icon(Icons.navigate_next),),
            )
        ),
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(leading: Icon(Icons.payments_outlined), title: Text('Pagos y cobros'), trailing: Icon(Icons.navigate_next),),
            )
        ),
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(leading: Icon(Icons.notifications_outlined), title: Text('Notificaciones'), trailing: Icon(Icons.navigate_next),),
            )
        ),
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(leading: Icon(Icons.verified_user_outlined), title: Text('Verifica tu identidad'), trailing: Icon(Icons.navigate_next),),
            )
        ),
      ),
      const Divider(),
    ];

    List<Widget> listaAnfitrion = [
      const Padding(
          padding: EdgeInsets.all(4.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: ListTile(title: Text('Modo anfitrión', style: MyFiltersPage.inputDecoratorLabelStyle),),
              )
          )
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(leading: Icon(Icons.add_home_outlined), title: Text('Publica tu espacio'), trailing: Icon(Icons.navigate_next),),
            )
        ),
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(leading: Icon(Icons.info_outlined), title: Text('Más información sobre como publicar tu espacio'), trailing: Icon(Icons.navigate_next),),
            )
        ),
      ),
      const Divider(),
    ];

    List<Widget> listaAsistencia = [
      const Padding(
          padding: EdgeInsets.all(4.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: ListTile(title: Text('Asistencia', style: MyFiltersPage.inputDecoratorLabelStyle),),
              )
          )
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(leading: Icon(Icons.help_outline_outlined), title: Text('Visita el Centro de ayuda'), trailing: Icon(Icons.navigate_next),),
            )
        ),
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(leading: Icon(Icons.health_and_safety_outlined), title: Text('Ayuda con problemas de seguridad'), trailing: Icon(Icons.navigate_next),),
            )
        ),
      ),
      const Divider(),
    ];

    List<Widget> listaLegal = [
      const Padding(
          padding: EdgeInsets.all(4.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: double.infinity,
                child: ListTile(title: Text('Legal', style: MyFiltersPage.inputDecoratorLabelStyle),),
              )
          )
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(leading: Icon(Icons.import_contacts_outlined), title: Text('Términos de servicio'), trailing: Icon(Icons.navigate_next),),
            )
        ),
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: ListTile(leading: Icon(Icons.import_contacts_outlined), title: Text('Politica de privacidad'), trailing: Icon(Icons.navigate_next),),
            )
        ),
      ),
      const Divider(),
    ];

    Widget cerrarSesion = const Padding(
      padding: EdgeInsets.all(4.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 80,
            width: double.infinity,
            child: Column(
              children: [
                Spacer(flex: 1,),
                ListTile(leading: Icon(Icons.logout_outlined), title: Text('Cerrar sesión', style: MyFiltersPage.underlinedStyle,),),
              ],
            ),
          )
      ),
    );

    List<Widget> listViewChildren = [tarjetaPerfil] + listaConfiguracion + listaAnfitrion + listaAsistencia + listaLegal + [cerrarSesion];

    return Container(
      color: Colors.white,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        children: listViewChildren,
      ),
    );
  }

}
