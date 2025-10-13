import 'dart:io';

extension SupportingPlatform on Platform {
  static bool get isAurora => Platform.isLinux;
}
