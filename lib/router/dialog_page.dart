// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// dialog_page.dart
import 'package:flutter/material.dart';

class DialogPage<T> extends Page<T> {
  const DialogPage({super.key, required this.child});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
    context: context,
    settings: this,
    builder: (context) => child,
  );
}
