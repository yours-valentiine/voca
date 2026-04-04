import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/features/updating/updating_notifier.dart';
import 'package:voca/router/routes.dart';
import 'package:voca/shared/service/updater/models/version_model.dart';
import 'package:voca/shared/util/context_helpers.dart';

class UpdatingScreen extends ConsumerWidget {
  const UpdatingScreen({super.key, required this.model});

  final VersionModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(updatingNotifierProvider(model).notifier);
    final state = ref.watch(updatingNotifierProvider(model));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: state.maybeWhen(
          started: () => IconButton(
            onPressed: () => context.go(Routes.dictionary.location),
            icon: const Icon(Icons.close),
          ),
          ready: (_) => IconButton(
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    translations(context).updating.ready.dialog.title,
                  ),
                  content: Text(
                    translations(context).updating.ready.dialog.content,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(false),
                      child: Text(translations(context).base.cancel),
                    ),
                    TextButton(
                      onPressed: () => context.pop(true),
                      child: Text(translations(context).base.confirm),
                    ),
                  ],
                ),
              );

              if (result ?? false) {
                await notifier.abortInstall();

                if (context.mounted) context.go(Routes.dictionary.location);
              }
            },
            icon: const Icon(Icons.close),
          ),
          error: (_) => IconButton(
            onPressed: () => context.go(Routes.dictionary.location),
            icon: const Icon(Icons.close),
          ),
          orElse: () => null,
        ),
        title: Text(translations(context).updating.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: state.when(
          started: () => Column(
            crossAxisAlignment: .stretch,
            children: [
              Text(
                translations(context).updating.started.title,
                style: typography(context).titleMedium,
              ),
              Expanded(
                child: Markdown(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  data: notifier.model.body,
                ),
              ),
              FilledButton.icon(
                onPressed: () async => await notifier.downloadLatest(),
                icon: const Icon(Icons.download),
                label: Text(translations(context).updating.started.download),
              ),
            ],
          ),
          downloading: (total, count) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  Text(translations(context).updating.downloading.title),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: count / total,
                    // ignore: deprecated_member_use
                    year2023: false,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    translations(context).updating.downloading.progress(
                      count: count.toStringAsFixed(2),
                      total: total.toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ready: (_) => Column(
            crossAxisAlignment: .stretch,
            mainAxisAlignment: .center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: colorScheme(context).primary,
              ),
              const SizedBox(height: 12),
              Text(
                translations(context).updating.ready.title,
                textAlign: .center,
                style: typography(
                  context,
                ).titleMedium?.copyWith(color: colorScheme(context).primary),
              ),
            ],
          ),
          error: (error) => Column(
            mainAxisAlignment: .center,
            children: [
              Text(error.toString()),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(translations(context).updating.errorButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
