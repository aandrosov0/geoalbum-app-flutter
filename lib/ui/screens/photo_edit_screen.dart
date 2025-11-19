import 'dart:io';

import 'package:app/ui/routes/routes.dart';
import 'package:flutter/material.dart';

class PhotoEditScreen extends StatefulWidget {
  const PhotoEditScreen({super.key});

  @override
  State<PhotoEditScreen> createState() => _PhotoEditScreenState();
}

class _PhotoEditScreenState extends State<PhotoEditScreen> {
  late final NavigatorState _navigatorState;

  PhotoViewRoute? _arguments;

  File? _photo;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _navigatorState = Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактирование')),
      body: Container(),
    );
  }
}
