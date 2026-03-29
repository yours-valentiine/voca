// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// word_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/router/routes.dart';
import 'package:voca/shared/util/context_helpers.dart';
import 'package:voca/shared/util/object_helper.dart';

class WordScreen extends ConsumerWidget {
  const WordScreen({super.key, required this.wordId});

  final UuidValue wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wordNotifierProvider(wordId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              final isRefresh = await context.push<bool>(
                Routes.editWord.location,
                extra: wordId,
              );

              if (isRefresh ?? false) {
                ref.read(wordNotifierProvider(wordId).notifier).refresh();
              }
            },
            tooltip: translations(context).aboutWord.editToolip,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: state.when(
            data: (data) {
              return Column(
                crossAxisAlignment: .stretch,
                spacing: 12,
                children: [
                  DataBlock(
                    color: colorScheme(context).surfaceContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Column(
                        crossAxisAlignment: .center,
                        children: [
                          Text(
                            data.word,
                            style: typography(context).headlineMedium,
                          ),
                          if (data.transcription.isNotNull)
                            Text(
                              data.transcription!,
                              style: typography(context).bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (data.translates.isNotEmpty)
                    DataBlock(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: data.translates.length,
                        itemBuilder: (context, index) {
                          final currentTranslate = data.translates[index];

                          return Text(
                            "${index + 1}. ${currentTranslate.translate}",
                          );
                        },
                      ),
                    ),

                  if (data.note.isNotNull)
                    DataBlock(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            translations(context).aboutWord.note,
                            style: typography(context).labelMedium,
                          ),
                          Text(data.note!),
                        ],
                      ),
                    ),
                ],
              );
            },
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: () => Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

class DataBlock extends StatelessWidget {
  const DataBlock({super.key, this.color, required this.child});

  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(0),
      color: color ?? colorScheme(context).surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        child: child,
      ),
    );
  }
}
