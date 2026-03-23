import 'dart:io';

class PlatfromDetector {
  static bool get isDesktop =>
      Platform.isWindows ||
      Platform.isFuchsia ||
      Platform.isMacOS ||
      Platform.isLinux;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
