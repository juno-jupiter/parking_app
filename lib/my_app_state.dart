import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  bool openedLocationCard = false;
  String languageTag = 'es-ES';
  bool isListView = true;

  void toggleLocationCard() {
    openedLocationCard = !openedLocationCard;
    notifyListeners();
  }

  void toggleMapView() {
    isListView = false;
    notifyListeners();
  }

  void toggleListView() {
    isListView = true;
    notifyListeners();
  }

}
