import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:app/utils/photos.dart';
import 'package:app/ui/routes/routes.dart';
import 'package:app/ui/widgets/clickable_image.dart';

class PhotosMapScreen extends StatefulWidget {
  const PhotosMapScreen({super.key});

  @override
  State<PhotosMapScreen> createState() => _PhotosMapScreenState();
}

class _PhotosMapScreenState extends State<PhotosMapScreen> {
  static const (int, int) imageRenderingSize = (60, 60);
  static const maxZoomIn = 20.0;
  static const maxZoomOut = 3.0;

  static const _zoomStrength = 1.0;
  static const _initialZoom = 10.0;

  final _mapController = MapController();

  late final NavigatorState _navigatorState;

  List<Marker> _markers = [];

  PhotosMapRoute? _arguments;

  @override
  void initState() {
    super.initState();

    _navigatorState = Navigator.of(context);
    _loadMarkers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _arguments = ModalRoute.settingsOf(context)!.arguments as PhotosMapRoute;
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter =
        _arguments!.initialLocation ?? const LatLng(54.32, 48.38);
      
    print(initialCenter);
    final mapOptions = MapOptions(
      initialCenter: initialCenter,
      initialZoom: _initialZoom,
      maxZoom: maxZoomIn,
      minZoom: maxZoomOut
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Метки на карте')),
      body: FlutterMap(
        mapController: _mapController,
        options: mapOptions,
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'aandrosov.geoalbum.app',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8.0,
        children: [
          FloatingActionButton(
            onPressed: _zoomIn,
            tooltip: 'Приблизить',
            heroTag: 'zoomIn',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _zoomOut,
            tooltip: 'Отдалить',
            heroTag: 'zoomOut',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  void _zoomIn() {
    final camera = _mapController.camera;
    final updatedZoom = camera.zoom + _zoomStrength;

    if (updatedZoom < maxZoomIn) {
      _mapController.move(camera.center, updatedZoom);
    }
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    final updatedZoom = camera.zoom - _zoomStrength;

    if (updatedZoom > maxZoomOut) {
      _mapController.move(camera.center, updatedZoom);
    }
  }

  void _loadPhoto(String path) {
    _navigatorState.pushNamed(
      '$PhotoViewRoute',
      arguments: PhotoViewRoute(photoPath: path),
    );
  }

  void _loadMarkers() async {
    final List<Marker> markers = [];

    final photos = await listAllPhotos();

    for (final photo in photos) {
      final location = await extractPhotoLocation(photo);
      if (location != null) {
        markers.add(
          Marker(
            point: location,
            child: ClickableImage(
              image: FileImage(File(photo)),
              onPressed: () {
                _loadPhoto(photo);
              },
              filterQuality: FilterQuality.low,
              cacheWidth: imageRenderingSize.$1,
              cacheHeight: imageRenderingSize.$2
            ),
          ),
        );
      }
    }
    setState(() => _markers = markers);
  }
}
