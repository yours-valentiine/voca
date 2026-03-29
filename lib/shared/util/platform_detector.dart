// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// platform_detector.dart
import 'dart:io';

class PlatfromDetector {
  static bool get isDesktop =>
      Platform.isWindows ||
      Platform.isFuchsia ||
      Platform.isMacOS ||
      Platform.isLinux;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
