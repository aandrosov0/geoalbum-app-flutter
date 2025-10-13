import 'dart:io';

import 'package:flutter/material.dart';

import 'package:app/utils/photos.dart';
import 'package:app/ui/routes/routes.dart';
import 'package:app/ui/widgets/clickable_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final NavigatorState _navigatorState;
  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();

    _navigatorState = Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Изображения')),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        itemCount: _photos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisExtent: 200,
          mainAxisSpacing: 10,
        ),
        itemBuilder:
            (_, index) => ClickableImage(
              image: FileImage(File(_photos[index])),
              onPressed: () {
                _loadPhoto(_photos[index]);
              },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openMap,
        tooltip: 'Открыть карту',
        child: const Icon(Icons.map),
      ),
    );
  }

  void _loadPhotos() async {
    final photos = await listAllPhotos();
    setState(() => _photos = photos);
  }

  void _loadPhoto(String path) {
    _navigatorState.pushNamed(
      '$PhotoViewRoute',
      arguments: PhotoViewRoute(photoPath: path),
    );
  }

  void _openMap() {
    _navigatorState.pushNamed('$PhotosMapRoute', arguments: PhotosMapRoute());
  }
}
