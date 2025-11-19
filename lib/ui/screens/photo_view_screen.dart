import 'dart:io';

import 'package:app/ui/routes/routes.dart';
import 'package:app/ui/widgets/plank.dart';
import 'package:app/utils/files.dart';
import 'package:app/utils/photos.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_cropper_aurora/image_cropper_aurora.dart';
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
  late final TextEditingController _photoWidthController;
  late final TextEditingController _photoHeightController;

  LatLng? _photoLocation;

  PhotoViewRoute? _arguments;

  File? _photo;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _navigatorState = Navigator.of(context);
    _fileNameController = TextEditingController();
    _photoWidthController = TextEditingController();
    _photoHeightController = TextEditingController();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _photoWidthController.dispose();
    _photoHeightController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _arguments = ModalRoute.settingsOf(context)!.arguments as PhotoViewRoute;
    _photo = File(_arguments!.photoPath);
    _loadLocation();
  }

  Future<void> _cropImage(String filePath) async {
    if (filePath.isEmpty) return;
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        uiSettings: [
          AuroraUiSettings(
            context: context,
            hasRightRotation: true,
            hasLeftRotation: true,
            gridColor: Colors.black,
            scrimColor: Colors.black,
            gridInnerColor: Colors.red,
            gridCornerColor: Colors.amber,
            cropButtonText: const Text('Применить изменения'),
          ),
        ],
      );

      if (croppedFile != null) {
        final newPath = croppedFile.path;
        _photo = File(newPath);

        setState(() {});
        if (!mounted) return;
      }
    } catch (e, stackTrace) {
      debugPrint('Error cropping image: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cropping image: $e')));
      }
    }
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
                  PopupMenuItem(
                    onTap: () => _cropImage(_photo?.path ?? ''),
                    child: const Text('Редактировать'),
                  ),
                  PopupMenuItem(
                    onTap: _onShare,
                    child: const Text('Поделиться'),
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
            child: PhotoView(imageProvider: FileImage(_photo ?? File(''))),
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

  void _onShare() {
    final path = _photo?.path ?? '';
    final uri = Uri.parse('file:$path');
  }

  Future<void> _showFileRenamingDialog() {
    _fileNameController.text = path.basenameWithoutExtension(
      _photo?.path ?? '',
    );

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
