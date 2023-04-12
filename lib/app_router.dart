import 'package:final_map_project/constants/my_strings.dart';
import 'package:final_map_project/screens/map_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  AppRouter() {}

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mapScreen:
        return MaterialPageRoute(
          builder: (_) => const MapScreen(),
        );
    }
    return null;
  }
}
