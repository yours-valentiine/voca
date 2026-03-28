import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid_value.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/router/routes.dart';
import 'package:voca/shared/model/word_model.dart';
import 'package:voca/shared/util/context_helpers.dart';
import 'package:voca/shared/util/object_helper.dart';

class DictionaryScreen extends ConsumerWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dictionaryNotifierProvider);
    final notifier = ref.watch(dictionaryNotifierProvider.notifier);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          centerTitle: true,
          title: ref
              .watch(currentDictionaryNotifierProvider)
              .maybeWhen(
                data: (data) => Text(data.name),
                orElse: () => const SizedBox.shrink(),
              ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: switch (state) {
            AsyncLoading() => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            AsyncError(error: final err) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(err.toString())),
            ),
            AsyncData(value: final data) => _buildDictionary(
              context,
              data,
              onCardTap: (wordId) =>
                  context.push(Routes.word.location, extra: wordId),
              onEditTap: (wordId) =>
                  context.push(Routes.editWord.location, extra: wordId),
              onDeleteTap: (wordId) async => notifier.deleteWord(wordId),
            ),
          },
        ),
      ],
    );
  }

  Widget _buildDictionary(
    BuildContext context,
    List<WordModel> words, {
    required void Function(UuidValue) onCardTap,
    required void Function(UuidValue) onEditTap,
    required void Function(UuidValue) onDeleteTap,
  }) {
    if (words.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            translations(context).placeholder.empty,
            style: typography(context).headlineSmall,
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final currentWord = words[index];

        return ContextMenuRegion(
          contextMenu: ContextMenu(
            entries: <ContextMenuEntry>[
              MenuItem(
                label: Text(translations(context).base.edit),
                icon: const Icon(Icons.edit_outlined),
                onSelected: (value) => onEditTap(currentWord.wordId!),
              ),
              MenuItem(
                label: Text(translations(context).base.delete),
                icon: const Icon(Icons.delete_outline),
                onSelected: (value) => onDeleteTap(currentWord.wordId!),
              ),
            ],
          ),
          child: Card(
            key: ValueKey(currentWord.wordId!),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            color: colorScheme(context).surfaceContainerLow,
            clipBehavior: .antiAlias,
            child: InkWell(
              onTap: () => onCardTap(currentWord.wordId!),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Wrap(
                      verticalDirection: .up,
                      children: [
                        Text(
                          currentWord.word,
                          style: typography(context).titleMedium,
                        ),
                        const SizedBox(width: 8),
                        if (currentWord.transcription.isNotNull)
                          Text(currentWord.transcription!),
                      ],
                    ),
                    if (currentWord.translates.isNotEmpty)
                      Text(
                        currentWord.formattedTranslates,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: typography(context).bodyMedium,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
