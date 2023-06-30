import 'package:flutter/material.dart';

class MyFiltersPage extends StatefulWidget {
  const MyFiltersPage({super.key});

  @override
  State<MyFiltersPage> createState() => _MyFiltersPageState();
}

class _MyFiltersPageState extends State<MyFiltersPage> {

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
