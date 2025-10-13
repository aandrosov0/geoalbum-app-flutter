import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_view/photo_view.dart';

import 'package:app/utils/photos.dart';
import 'package:app/ui/routes/routes.dart';
import 'package:app/ui/widgets/plank.dart';

class PhotoViewScreen extends StatefulWidget {
  const PhotoViewScreen({super.key});

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  late final NavigatorState _navigatorState;
  LatLng? _photoLocation;

  PhotoViewRoute? _arguments;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _navigatorState = Navigator.of(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _arguments = ModalRoute.settingsOf(context)!.arguments as PhotoViewRoute;
    _loadLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Просмотр изображения')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_photoLocation == null)
            Plank('Геометка отсутсвует.\nИзображения не будет на карте.'),
          Expanded(
            flex: 1,
            child: PhotoView(
              imageProvider: FileImage(File(_arguments!.photoPath)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openMap,
        tooltip: 'Открыть на карте',
        child:
            _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.map),
      ),
    );
  }

  void _openMap() {
    _navigatorState.pushNamed(
      '$PhotosMapRoute',
      arguments: PhotosMapRoute(initialLocation: _photoLocation),
    );
  }

  void _loadLocation() async {
    setState(() => _isLoading = true);
    _photoLocation = await extractPhotoLocation(_arguments!.photoPath);
    setState(() => _isLoading = false);
  }
}
