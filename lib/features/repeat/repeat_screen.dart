import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca/features/repeat/repeat_notifier.dart';
import 'package:voca/router/navigation.dart';
import 'package:voca/router/routes.dart';
import 'package:voca/shared/util/context_helpers.dart';

class RepeatScreen extends ConsumerWidget {
  const RepeatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(translations(context).repeat.title),
          centerTitle: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: ref
              .watch(repeatStaticsProvider)
              .when(
                data: (data) {
                  if (data.allCount == 0) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          translations(context).repeat.empty,
                          style: typography(context).headlineSmall,
                        ),
                      ),
                    );
                  }

                  return SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Card.filled(
                          elevation: 0,
                          color: colorScheme(context).secondaryContainer,
                          child: SizedBox(
                            height: 140,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: .center,
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Text(
                                    translations(context).repeat.ready.title,
                                    style: typography(context).titleMedium
                                        ?.copyWith(
                                          color: colorScheme(
                                            context,
                                          ).onSecondaryContainer,
                                        ),
                                  ),
                                  Text.rich(
                                    translations(context).repeat.ready.all(
                                      n: data.allCount,
                                      nBuilder: (count) => TextSpan(
                                        text: count.toString(),
                                        style: typography(context)
                                            .headlineMedium
                                            ?.copyWith(
                                              color: colorScheme(
                                                context,
                                              ).onSecondaryContainer,
                                              fontWeight: .w600,
                                            ),
                                      ),
                                      small: (text) => TextSpan(
                                        text: text,
                                        style: typography(context).bodyMedium
                                            ?.copyWith(
                                              color: colorScheme(
                                                context,
                                              ).onSecondaryContainer,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    spacing: 6,
                                    mainAxisAlignment: .end,
                                    children: [
                                      if (data.newCount > 0)
                                        InfoChip(
                                          label: translations(
                                            context,
                                          ).repeat.ready.kNew(n: data.newCount),
                                          leading: Icons.trending_up_outlined,
                                        ),
                                      InfoChip(
                                        label: translations(context)
                                            .repeat
                                            .ready
                                            .durations(n: data.duration),
                                        leading: Icons.alarm_outlined,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 75,
                          child: Row(
                            crossAxisAlignment: .stretch,
                            mainAxisAlignment: .start,
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => context.pushRoute(
                                    Routes.spacedRepetition,
                                  ),
                                  child: Text(
                                    translations(context).repeat.startButton,
                                    style: typography(context).headlineSmall
                                        ?.copyWith(
                                          color: colorScheme(context).onPrimary,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                error: (error, stackTrace) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Text(error.toString()),
                ),
                loading: () => SliverFillRemaining(
                  hasScrollBody: false,
                  child: CircularProgressIndicator(),
                ),
              ),
        ),
      ],
    );
  }

  /*   PopupMenuItem _buildMenuIconItem({
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem(
      child: Row(
        crossAxisAlignment: .end,
        mainAxisAlignment: .start,
        spacing: 16,
        children: [Icon(size: 18, icon), Text(label)],
      ),
    );
  } */
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, this.leading, required this.label});

  final IconData? leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme(context).surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          spacing: 4,
          children: [
            if (leading != null) Icon(size: 16, leading),
            Text(label, style: typography(context).labelSmall),
          ],
        ),
      ),
    );
  }
}
