import 'dart:io';

extension Files on File {
  Future<File> renameIgnoringExtension(String name) {
    final separator = path.lastIndexOf(Platform.pathSeparator);
    final newPath =
        '${path.substring(0, separator + 1)}$name.${path.split('.').lastOrNull ?? ''}';

    return rename(newPath);
  }
}
