import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:app/ui/screens/home_screen.dart';
import 'package:app/ui/screens/photo_view_screen.dart';
import 'package:app/ui/screens/photos_map_screen.dart';

import '../screens/photo_edit_screen.dart';

class HomeRoute {
  const HomeRoute();
}

class PhotoViewRoute {
  final String photoPath;

  const PhotoViewRoute({required this.photoPath});
}

class PhotosMapRoute {
  final LatLng? initialLocation;

  const PhotosMapRoute({this.initialLocation});
}

class PhotoEditRoute {
  final String photoPath;

  const PhotoEditRoute({required this.photoPath});
}

Map<String, WidgetBuilder> get routes => {
  '/': (_) => const HomeScreen(),
  '$HomeRoute': (_) => const HomeScreen(),
  '$PhotoViewRoute': (_) => const PhotoViewScreen(),
  '$PhotosMapRoute': (_) => const PhotosMapScreen(),
  '$PhotoEditRoute': (_) => const PhotoEditScreen(),
};
