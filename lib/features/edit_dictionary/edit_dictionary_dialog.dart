import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/shared/model/dictionary_model.dart';
import 'package:voca/shared/util/context_helpers.dart';

class EditDictionaryDialog extends ConsumerStatefulWidget {
  const EditDictionaryDialog({super.key, this.dictionaryId});

  final UuidValue? dictionaryId;

  @override
  ConsumerState<EditDictionaryDialog> createState() =>
      _EditDictionaryDialogState();
}

class _EditDictionaryDialogState extends ConsumerState<EditDictionaryDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncControllers(DictionaryModel model) {
    if (_nameController.text != model.name) {
      _nameController.text = model.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      editDictionaryNotifierProvider(widget.dictionaryId),
    );
    final notifier = ref.watch(
      editDictionaryNotifierProvider(widget.dictionaryId).notifier,
    );

    return state.when(
      data: (data) {
        _syncControllers(data);
        return AlertDialog(
          title: Text(translations(context).menu.create.title),
          content: Form(
            child: TextField(
              controller: _nameController,
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
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
    );
  }
}
