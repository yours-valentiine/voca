import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:voca/router/routes.dart';
import 'package:voca/shared/ui/theme/spacing.dart';
import 'package:voca/shared/util/window_size.dart';

Future<T?> showResponsiveDialog<T>({
  required BuildContext context,
  required Widget content,
}) async => showDialog<T>(
  context: context,
  builder: (context) {
    final windowSize = WindowSize.of(context);
    if (windowSize == .compact || windowSize == .medium) {
      return Dialog.fullscreen(child: content);
    } else {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: Spacings.M,
          vertical: Spacings.S,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 280,
            maxWidth: 560,
            maxHeight: 600,
          ),
          child: content,
        ),
      );
    }
  },
);

extension ContextHelper on BuildContext {
  void pushRoute(Routes route) => push(route.location);
}
