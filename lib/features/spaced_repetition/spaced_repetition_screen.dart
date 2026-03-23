// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/features/spaced_repetition/spaced_repetition_notifier.dart';
import 'package:voca/shared/util/context_helpers.dart';

class SpacedRepetitionScreen extends ConsumerWidget {
  const SpacedRepetitionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(spacedRepetitionNotifierProvider);
    final notifier = ref.watch(spacedRepetitionNotifierProvider.notifier);

    ref.listen(
      spacedRepetitionNotifierProvider.select((s) => s.value?.isFinished),
      (prev, next) {
        if (next ?? false) context.pop();
      },
    );

    return Scaffold(
      appBar: state.maybeWhen(
        data: (data) => AppBar(
          title: Row(
            crossAxisAlignment: .center,
            children: [
              Text(
                "${data.positionCard}/${data.allCount}",
                style: typography(context).titleMedium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: data.percentRepeated,
                  year2023: false,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (!data.hiddenWarningSkip) {
                  _showSkipDialog(context);
                } else {
                  notifier.skipCard();
                }
              },
              tooltip: translations(context).repeat.skip.tooltip,
              icon: const Icon(Icons.skip_next_outlined),
            ),
          ],
          actionsPadding: const EdgeInsets.only(right: 8),
        ),
        orElse: () => AppBar(title: LinearProgressIndicator()),
      ),
      body: state.when(
        data: (data) {
          final currentCard = data.currentCard;

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      "Input translate:",
                      style: typography(context).labelLarge,
                    ),
                    Text(
                      currentCard.word,
                      style: typography(context).headlineMedium,
                    ),
                    Column(
                      crossAxisAlignment: .end,
                      children: [
                        TextField(
                          decoration: InputDecoration(label: Text("Translate")),
                          autocorrect: false,
                          autofocus: true,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check),
                          label: Text(translations(context).repeat.check.title),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              data.currectCardState.maybeWhen(
                checked: (isCorrect) => Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BottomSheet(
                    onClosing: () {},
                    enableDrag: false,
                    builder: (context) {
                      return SizedBox(
                        height: isCorrect ? 240 : 160,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: .stretch,
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              isCorrect
                                  ? Text(
                                      "localization(context).correctAnswerTitle",
                                      style: typography(context).titleMedium,
                                    )
                                  : Text(
                                      "Incorrect",
                                      style: typography(context).titleMedium
                                          ?.copyWith(
                                            color: colorScheme(context).error,
                                          ),
                                    ),
                              Column(
                                spacing: 4.0,
                                crossAxisAlignment: .start,
                                children: [
                                  Text(
                                    data.currentCard.word,
                                    style: typography(context).titleMedium,
                                  ),
                                  Text(
                                    data.currentCard.translates.first.translate,
                                  ),
                                  if (isCorrect)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 28),
                                      child: Column(
                                        crossAxisAlignment: .start,
                                        spacing: 4.0,
                                        children: [
                                          Text(
                                            "Rating",
                                            style: typography(context).bodyLarge
                                                ?.copyWith(fontWeight: .w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              FilledButton.tonal(
                                onPressed: notifier.nextCard,
                                child: Text("Next"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                orElse: () => SizedBox.shrink(),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => CircularProgressIndicator(),
      ),
    );
  }

  void _showSkipDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final state = ref.watch(spacedRepetitionNotifierProvider);
        final notifier = ref.watch(spacedRepetitionNotifierProvider.notifier);

        return AlertDialog(
          title: Text(translations(context).repeat.skip.title),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 120,
                maxHeight: 180,
                minWidth: 240,
                maxWidth: 360,
              ),
              child: Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    translations(context).repeat.skip.content,
                    style: typography(context).bodyLarge,
                  ),
                  CheckboxListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    value: state.value?.hiddenWarningSkip ?? false,
                    onChanged: (value) =>
                        notifier.hiddenWarning(value ?? false),
                    title: Text(
                      translations(context).repeat.skip.hiddenMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                notifier.hiddenWarning(false);
                context.pop();
              },
              child: Text(translations(context).base.cancel),
            ),
            TextButton(
              onPressed: () {
                notifier.skipCard();
                context.pop();
              },
              child: Text(translations(context).repeat.skip.yes),
            ),
          ],
        );
      },
    ),
  );
}
