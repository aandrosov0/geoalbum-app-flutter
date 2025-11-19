import 'dart:io';

import 'package:app/ui/widgets/image_deletion_dialog.dart';
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
  static const (int, int) imageRenderingSize = (300, 300);

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
        itemBuilder: (_, index) => _buildImage(_photos[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openMap,
        tooltip: 'Открыть карту',
        child: const Icon(Icons.map),
      ),
    );
  }

  Widget _buildImage(String path) {
    return ClickableImage(
      image: FileImage(File(path), scale: 0.1),
      onPressed: () => _loadPhoto(path),
      onLongPress: () =>
          showDialog(
              context: context, builder: (context) =>
              ImageDeletionDialog(
                onCancel: Navigator.of(context).pop,
                onApply: () {
                  Navigator.of(context).pop();
                  _deleteImage(path);
                },
              )
          ),
      filterQuality: FilterQuality.low,
      cacheHeight: imageRenderingSize.$2,
    );
  }

  void _deleteImage(String path) async {
    await File(path).delete();
    setState(() { _loadPhotos(); });
  }

  void _loadPhotos() async {
    final photos = await listAllPhotos();
    setState(() => _photos = photos);
  }

  Future<void> _loadPhoto(String path) async {
    await _navigatorState.pushNamed(
      '$PhotoViewRoute',
      arguments: PhotoViewRoute(photoPath: path),
    );

    _loadPhotos();
  }

  void _openMap() {
    _navigatorState.pushNamed('$PhotosMapRoute', arguments: PhotosMapRoute());
  }
}
