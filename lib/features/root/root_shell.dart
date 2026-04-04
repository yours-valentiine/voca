// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// root_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/features/repeat/repeat_notifier.dart';
import 'package:voca/router/navigation.dart';
import 'package:voca/router/routes.dart';
import 'package:voca/shared/util/context_helpers.dart';

class RootShell extends ConsumerWidget {
  const RootShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  Widget _buildBadge(BuildContext context, {required Widget icon}) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(repeatStaticsProvider);

        return state.maybeWhen(
          data: (data) => data.allCount > 0
              ? Badge.count(count: data.allCount, child: icon)
              : icon,
          orElse: () => icon,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = [
      NavigationDestination(
        label: translations(context).root.dictionary,
        icon: const Icon(Icons.book_outlined),
        selectedIcon: const Icon(Icons.book),
      ),
      NavigationDestination(
        label: translations(context).root.repeat,
        icon: _buildBadge(context, icon: const Icon(Icons.repeat)),
      ),
    ];

    return Scaffold(
      drawer: _buildDrawer(context),
      floatingActionButton: switch (navigationShell.currentIndex) {
        0 => FloatingActionButton(
          onPressed: () {
            context.push(Routes.editWord.location, extra: null);
          },
          child: const Icon(Icons.add),
        ),
        _ => null,
      },
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        labelBehavior: .onlyShowSelected,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (value) => navigationShell.goBranch(value),
        destinations: destinations,
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      width: 240,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: .spaceBetween,
          children: [
            Consumer(
              builder: (context, ref, child) {
                final currentId = ref.watch(currentDictionaryNotifierProvider);
                final idNotifier = ref.watch(
                  currentDictionaryNotifierProvider.notifier,
                );
                final state = ref.watch(rootNotifierProvider);

                return state.when(
                  data: (data) {
                    return Column(
                      spacing: 8,
                      crossAxisAlignment: .stretch,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final dictionary = data[index];
                            return ContextMenuRegion(
                              contextMenu: ContextMenu(
                                entries: <ContextMenuEntry>[
                                  MenuItem(
                                    icon: const Icon(Icons.edit_outlined),
                                    label: Text(
                                      translations(context).base.edit,
                                    ),
                                    onSelected: (value) {
                                      context.push(
                                        Routes.editDictionary.location,
                                        extra: dictionary.dictionaryId,
                                      );
                                    },
                                  ),
                                  MenuItem(
                                    icon: const Icon(Icons.delete_outline),
                                    label: Text(
                                      translations(context).base.delete,
                                    ),
                                    onSelected: (_) async => await idNotifier
                                        .deleteSingle(dictionary.dictionaryId),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(dictionary.name),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    24,
                                  ),
                                ),
                                onTap: () async {
                                  await idNotifier.changeCurrent(
                                    dictionary.dictionaryId,
                                  );

                                  if (context.mounted) context.pop();
                                },
                                selected: dictionary == currentId.value,
                                selectedTileColor: colorScheme(
                                  context,
                                ).primaryContainer,
                                selectedColor: colorScheme(
                                  context,
                                ).onPrimaryContainer,
                              ),
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            context.push(
                              Routes.editDictionary.location,
                              extra: null,
                            );
                          },
                          child: Text(translations(context).menu.create.button),
                        ),
                      ],
                    );
                  },
                  error: (error, stakcTrace) =>
                      Center(child: Text(error.toString())),
                  loading: () => const SizedBox.shrink(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(translations(context).settings.title),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(24),
              ),
              onTap: () => context.pushRoute(Routes.settings),
            ),
          ],
        ),
      ),
    );
  }
}
