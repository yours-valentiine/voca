// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// spaced_repetition_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/features/spaced_repetition/spaced_repetition_notifier.dart';
import 'package:voca/shared/model/repeat_word_model.dart';
import 'package:voca/shared/util/context_helpers.dart';

class SpacedRepetitionScreen extends ConsumerStatefulWidget {
  const SpacedRepetitionScreen({super.key});

  @override
  ConsumerState<SpacedRepetitionScreen> createState() =>
      _SpacedRepetitionScreenState();
}

class _SpacedRepetitionScreenState
    extends ConsumerState<SpacedRepetitionScreen> {
  final TextEditingController _answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              enableFeedback: false,
              onPressed: data.currectCardState.maybeWhen<VoidCallback?>(
                checked: (_) => null,
                orElse: () => () {
                  if (!data.hiddenWarningSkip) {
                    _showSkipDialog(context);
                  } else {
                    notifier.skipCard();
                  }
                },
              ),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        translations(context).repeat.exersize.title,
                        style: typography(context).labelLarge,
                      ),
                      Text(
                        currentCard.word,
                        style: typography(context).headlineMedium,
                      ),
                      Column(
                        crossAxisAlignment: .end,
                        children: [
                          TextFormField(
                            enabled: data.currectCardState.maybeWhen(
                              checked: (_) => false,
                              orElse: () => null,
                            ),
                            controller: _answerController,
                            decoration: InputDecoration(
                              label: Text(
                                translations(
                                  context,
                                ).repeat.exersize.answerLabel,
                              ),
                            ),
                            autocorrect: false,
                            autofocus: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return translations(context).repeat.exersize.validationError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: data.currectCardState.maybeWhen(
                              checked: (_) => null,
                              orElse: () => () async {
                                if (_formKey.currentState!.validate()) {
                                  await notifier.checkCard(
                                    _answerController.text,
                                  );
                                }
                              },
                            ),
                            icon: const Icon(Icons.check),
                            label: Text(
                              translations(context).repeat.check.title,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              data.currectCardState.maybeWhen(
                checked: (isCorrect) => _buildBottomSheet(
                  isCorrect,
                  data.currentCard,
                  data.rating,
                  onRaitingChange: notifier.setRating,
                  onNextTap: () {
                    notifier.nextCard();
                    _answerController.clear();
                  },
                ),
                orElse: () => SizedBox.shrink(),
              ),
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => CircularProgressIndicator(year2023: false),
      ),
    );
  }

  Positioned _buildBottomSheet(
    bool isCorrect,
    RepeatWordModel card,
    ExerciseRating rating, {
    required ValueChanged<ExerciseRating> onRaitingChange,
    required VoidCallback onNextTap,
  }) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: BottomSheet(
        onClosing: () {},
        enableDrag: false,
        builder: (context) {
          return SizedBox(
            height: isCorrect ? 280 : 160,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: .stretch,
                mainAxisAlignment: .spaceBetween,
                children: [
                  isCorrect
                      ? Text(
                          translations(context).repeat.check.correctTitle,
                          style: typography(context).titleMedium,
                        )
                      : Text(
                          translations(context).repeat.check.incorrectTitle,
                          style: typography(context).titleMedium?.copyWith(
                            color: colorScheme(context).error,
                          ),
                        ),
                  Column(
                    spacing: 4.0,
                    crossAxisAlignment: .start,
                    children: [
                      Text(card.word, style: typography(context).titleMedium),
                      Text(card.translates.first.translate),
                      if (isCorrect)
                        Column(
                          crossAxisAlignment: .center,
                          spacing: 8.0,
                          children: [
                            Text(
                              translations(context).repeat.check.rating.title,
                              style: typography(
                                context,
                              ).bodyLarge?.copyWith(fontWeight: .w600),
                              textAlign: .center,
                            ),
                            Row(
                              mainAxisAlignment: .spaceEvenly,
                              children: [
                                RatingButton(
                                  icon: const Text("\u{1F638}"),
                                  onSelected: () => onRaitingChange(.easy),
                                  isSelected: rating == .easy,
                                  label: translations(
                                    context,
                                  ).repeat.check.rating.easy,
                                ),
                                RatingButton(
                                  icon: const Text("\u{1F63C}"),
                                  onSelected: () => onRaitingChange(.good),
                                  isSelected: rating == .good,
                                  label: translations(
                                    context,
                                  ).repeat.check.rating.good,
                                ),
                                RatingButton(
                                  icon: const Text("\u{1F640}"),
                                  onSelected: () => onRaitingChange(.hard),
                                  isSelected: rating == .hard,
                                  label: translations(
                                    context,
                                  ).repeat.check.rating.hard,
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                  FilledButton.tonal(
                    onPressed: onNextTap,
                    child: Text(translations(context).repeat.check.next),
                  ),
                ],
              ),
            ),
          );
        },
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
                maxHeight: 220,
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

class RatingButton extends StatelessWidget {
  const RatingButton({
    super.key,
    required this.icon,
    required this.onSelected,
    required this.isSelected,
    required this.label,
  });

  final Widget icon;
  final VoidCallback onSelected;
  final bool isSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4.0,
      children: [
        IconButton.outlined(
          onPressed: onSelected,
          icon: icon,
          isSelected: isSelected,
        ),
        Text(label, style: typography(context).labelMedium),
      ],
    );
  }
}
