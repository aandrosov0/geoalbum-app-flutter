import 'dart:io';

import 'package:app/ui/routes/routes.dart';
import 'package:app/ui/widgets/image_deletion_dialog.dart';
import 'package:app/ui/widgets/plank.dart';
import 'package:app/utils/files.dart';
import 'package:app/utils/photos.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_cropper_aurora/image_cropper_aurora.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as path;
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

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
            dialogBackgroundColor: ColorScheme.of(context).surface,
            showSourceImagePath: false,
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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
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
      body: Stack(
        children: [
          Column(
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
          Container(
            padding: EdgeInsets.only(bottom: 18),
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _cropImage(_photo?.path ?? ''),
                  icon: const Icon(Icons.edit),
                  color: Colors.white,
                  padding: EdgeInsets.all(16),
                ),
                IconButton(
                  onPressed: _showDeleteDialog,
                  icon: const Icon(Icons.delete),
                  color: Colors.white,
                  padding: EdgeInsets.all(16),
                ),
                IconButton(
                  onPressed: _onShare,
                  icon: const Icon(Icons.share),
                  color: Colors.white,
                  padding: EdgeInsets.all(16),
                ),
              ],
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

  void _onDelete() async {
    _photo?.delete();
    Navigator.of(context).pop();
  }

  void _showDeleteDialog() async {
    return showDialog(
      context: context,
      builder:
          (context) => ImageDeletionDialog(
            onApply: () {
              Navigator.of(context).pop();
              _onDelete();
            },
            onCancel: Navigator.of(context).pop,
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
    final uri = Uri(scheme: 'file', path: path);
    launchUrl(uri, mode: LaunchMode.externalApplication);
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
