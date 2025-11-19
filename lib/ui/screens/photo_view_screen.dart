import 'dart:io';

import 'package:app/ui/routes/routes.dart';
import 'package:app/ui/widgets/plank.dart';
import 'package:app/utils/files.dart';
import 'package:app/utils/photos.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as path;
import 'package:photo_view/photo_view.dart';

class PhotoViewScreen extends StatefulWidget {
  const PhotoViewScreen({super.key});

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  late final NavigatorState _navigatorState;
  late final TextEditingController _fileNameController;

  LatLng? _photoLocation;

  PhotoViewRoute? _arguments;

  File? _photo;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _navigatorState = Navigator.of(context);
    _fileNameController = TextEditingController();
  }

  @override
  void dispose() {
    _fileNameController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _arguments = ModalRoute.settingsOf(context)!.arguments as PhotoViewRoute;
    _photo = File(_arguments!.photoPath);
    _loadLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Просмотр изображения'),
        actions: [
          PopupMenuButton(
            itemBuilder:
                (_) => [
                  PopupMenuItem(
                    onTap: _showFileRenamingDialog,
                    child: const Text('Переименовать'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_photoLocation == null)
            Plank('Геометка отсутствует.\nИзображения не будет на карте.'),
          Expanded(
            flex: 1,
            child: PhotoView(imageProvider: FileImage(_photo!)),
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
    _photoLocation = await extractPhotoLocationFromFile(_photo!);
    setState(() => _isLoading = false);
  }

  void _onRenameFile() async {
    final name = _fileNameController.text;
    _photo = await _photo?.renameIgnoringExtension(name);
  }

  Future<void> _showFileRenamingDialog() {
    _fileNameController.text = path.basenameWithoutExtension(_photo?.path ?? '');

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Изменение названия файла'),
            content: TextField(controller: _fileNameController),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('Отменить'),
              ),
              TextButton(
                onPressed: () {
                  _onRenameFile();
                  Navigator.of(context).pop();
                },
                child: const Text('Подтвердить'),
              ),
            ],
          ),
    );
  }
}
