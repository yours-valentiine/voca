// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// window_size.dart
import 'package:flutter/material.dart';

class WindowSize {
  WindowSize._();

  static WindowSizeData of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return switch (width) {
      < 600 => .compact,
      >= 600 && < 840 => .medium,
      >= 840 && < 1200 => .expanded,
      >= 1200 && < 1600 => .large,
      >= 1600 => .extraLarge,
      _ => .compact,
    };
  }
}

enum WindowSizeData {
  compact,
  medium,
  expanded,
  large,
  extraLarge;

  bool get isCompact => this == .compact;
  bool get isLarge => this == .large || this == .extraLarge;
}
