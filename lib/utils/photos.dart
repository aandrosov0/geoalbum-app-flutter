import 'dart:io';
import 'package:exif/exif.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app/utils/supporting_platform.dart';

Future<List<Directory>?> getPhotosDirectories() async {
  if (SupportingPlatform.isAurora) {
    return await getExternalStorageDirectories(type: StorageDirectory.pictures);
  } else if (SupportingPlatform.isAndroid) {
    var isGranted = await Permission.photos.request().isGranted;
    if (isGranted) {
      final pictures = new Directory('/storage/sdcard0/Pictures');
      final dcim = new Directory('/storage/sdcard0/DCIM');
      return [pictures, dcim];
    }

    return [];
  }
  throw Exception('Unsupported operating system');
}

Future<List<String>> listAllPhotos() async {
  final photos = <String>[];
  final fileNameRegex = RegExp(r'^(.*.jpg)|(.*.png)$');
  final picturesDirs = await getPhotosDirectories();
  print(picturesDirs);

  picturesDirs?.forEach((dir) {
    for (final file in dir.listSync(recursive: true)) {
      final path = file.path;
      if (fileNameRegex.hasMatch(path)) {
        photos.add(path);
      }
    }
  });

  return photos;
}

Future<LatLng?> extractPhotoLocation(String path) async {
  final fileBytes = File(path).readAsBytesSync();
  final data = await readExifFromBytes(fileBytes);

  if (data.isEmpty) {
    return null;
  }

  final latRef = data['GPS GPSLatitudeRef']?.toString();
  var latVal = _gpsValuesToFloat(data['GPS GPSLatitude']?.values);
  final lngRef = data['GPS GPSLongitudeRef']?.toString();
  var lngVal = _gpsValuesToFloat(data['GPS GPSLongitude']?.values);

  if (latRef == null || latVal == null || lngRef == null || lngVal == null) {
    return null;
  }

  if (latRef == 'S') {
    latVal *= -1;
  }

  if (lngRef == 'W') {
    lngVal *= -1;
  }

  return LatLng(latVal, lngVal);
}

double? _gpsValuesToFloat(IfdValues? values) {
  if (values == null || values is! IfdRatios) {
    return null;
  }

  double sum = 0.0;
  double unit = 1.0;

  for (final v in values.ratios) {
    sum += v.toDouble() * unit;
    unit /= 60.0;
  }

  return sum;
}
