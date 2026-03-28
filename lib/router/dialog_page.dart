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
