import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/shared/util/context_helpers.dart';

class CreateDictionaryDialog extends ConsumerWidget {
  const CreateDictionaryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(createDictionaryNotifierProvider.notifier);

    return AlertDialog(
      title: Text(translations(context).menu.create.title),
      content: Form(
        child: TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            label: Text(translations(context).menu.create.field),
          ),
          autofocus: true,
          onChanged: notifier.setName,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(translations(context).base.cancel),
        ),
        TextButton(
          onPressed: () async {
            final isSave = await notifier.saveData();

            if (isSave && context.mounted) context.pop();
          },
          child: Text(translations(context).menu.create.formButton),
        ),
      ],
    );
  }
}
