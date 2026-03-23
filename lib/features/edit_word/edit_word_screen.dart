import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid_value.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/shared/model/word_model.dart';
import 'package:voca/shared/util/context_helpers.dart';

class EditWordScreen extends ConsumerStatefulWidget {
  final UuidValue? wordId;
  const EditWordScreen({super.key, required this.wordId});

  @override
  ConsumerState<EditWordScreen> createState() => _EditWordScreenState();
}

class _EditWordScreenState extends ConsumerState<EditWordScreen> {
  final _wordController = TextEditingController();
  final _transcriptionController = TextEditingController();
  final _translatesControllers = <UuidValue, TextEditingController>{};
  final _noteController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  /*
   *  Синхронизация данных контроллеров с данными в состоянии
   *  Проверяет данные на заполненность и обновляет контроллеры
   */
  void _syncControllers(WordModel model) {
    if (_wordController.text != model.word) {
      _wordController.text = model.word;
    }

    if (_transcriptionController.text != model.transcription) {
      _transcriptionController.text = model.transcription ?? '';
    }

    if (_noteController.text != model.note) {
      _noteController.text = model.note ?? '';
    }

    final currentIds = model.translates.map((t) => t.translateId).toSet();

    _translatesControllers.keys
        .where((id) => !currentIds.contains(id))
        .toList()
        .forEach((id) {
          _translatesControllers[id]!.dispose();
          _translatesControllers.remove(id);
        });

    for (final entry in model.translates) {
      if (!_translatesControllers.containsKey(entry.translateId)) {
        _translatesControllers[entry.translateId] = TextEditingController(
          text: entry.translate,
        );
      } else if (_translatesControllers[entry.translateId]!.text !=
          entry.translate) {
        _translatesControllers[entry.translateId]!.text = entry.translate;
      }
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _transcriptionController.dispose();
    _noteController.dispose();

    for (final c in _translatesControllers.values) {
      c.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editWordNotifierProvider(widget.wordId));
    final notifier = ref.watch(
      editWordNotifierProvider(widget.wordId).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        actions: [
          FilledButton.tonal(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              final isSave = await notifier.save();

              if (isSave && context.mounted) context.pop(true);
            },
            child: const Icon(Icons.check),
          ),
        ],
        actionsPadding: const EdgeInsets.only(right: 8),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: state.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text(error.toString()),
            data: (data) {
              _syncControllers(data);
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text(translations(context).aboutWord.word.title),
                      ),
                      autofocus: true,
                      controller: _wordController,
                      textInputAction: .next,
                      onChanged: notifier.setWord,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return translations(
                            context,
                          ).aboutWord.word.validation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text(
                          translations(context).aboutWord.transcription,
                        ),
                      ),
                      controller: _transcriptionController,
                      textInputAction: data.translates.isNotEmpty
                          ? .next
                          : .done,
                      onChanged: notifier.setTranscription,
                      onEditingComplete: data.translates.isEmpty
                          ? notifier.appendTranslate
                          : null,
                    ),
                    const SizedBox(height: 18),
                    Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        ReorderableListView.builder(
                          header: Text(
                            translations(context).aboutWord.translates,
                          ),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: data.translates.length,
                          onReorder: notifier.reorderTranslate,
                          itemBuilder: (context, index) {
                            final translate = data.translates[index];

                            return TranslateBlock(
                              key: ValueKey(translate.translateId),
                              index: index,
                              controller:
                                  _translatesControllers[translate.translateId],
                              onDeleteTap: () => notifier.removeTranslate(
                                translate.translateId,
                              ),
                              onChanged: (value) => notifier.setTranslate(
                                translate.translateId,
                                value,
                              ),
                              onLostFocus: () => notifier.clearTranslates(),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => notifier.appendTranslate(),
                          child: Text(
                            translations(context).aboutWord.addTranslate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(translations(context).aboutWord.note),
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: translations(
                              context,
                            ).aboutWord.placeholderNote,
                            border: InputBorder.none,
                          ),
                          onChanged: notifier.setNote,
                          minLines: 7,
                          maxLines: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class TranslateBlock extends StatelessWidget {
  final int index;
  final TextEditingController? controller;
  final void Function(String value)? onChanged;
  final VoidCallback? onLostFocus;
  final VoidCallback? onDeleteTap;

  const TranslateBlock({
    super.key,
    required this.index,
    this.controller,
    this.onDeleteTap,
    this.onLostFocus,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .center,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.move,
          child: ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_indicator),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: TranslateTextField(
            controller: controller,
            onLostFocus: onLostFocus,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 2),
        IconButton(onPressed: onDeleteTap, icon: const Icon(Icons.close)),
        /* IconButtonM3E(
          size: .xs,
          width: .narrow,
          onPressed: onDeleteTap,
          icon: const Icon(Icons.close),
        ), */
      ],
    );
  }
}

class TranslateTextField extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String value)? onChanged;
  final VoidCallback? onLostFocus;

  const TranslateTextField({
    super.key,
    this.controller,
    this.onChanged,
    this.onLostFocus,
  });

  @override
  State<TranslateTextField> createState() => _TranslateTextFieldState();
}

class _TranslateTextFieldState extends State<TranslateTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null && widget.controller!.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.onLostFocus != null) {
        widget.onLostFocus!();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            border: InputBorder.none,
            isCollapsed: true,
            fillColor: colorScheme(context).surfaceContainer,
          ),
          maxLines: null,
          style: typography(context).bodyLarge,
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
