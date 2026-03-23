import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/features/create_dictionary/create_dictionary_dialog.dart';
import 'package:voca/features/repeat/repeat_notifier.dart';
import 'package:voca/router/navigation.dart';
import 'package:voca/router/routes.dart';
import 'package:voca/shared/util/context_helpers.dart';

/* class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  Widget _buildBadge({required AsyncValue<int> value, required Widget icon}) {
    return value.when(
      data: (value) {
        return Badge(
          isLabelVisible: value > 0,
          label: value > 0 ? Text(value.toString()) : null,
          child: icon,
        );
      },
      error: (error, stackTrace) => icon,
      loading: () => icon,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewCountStream = ref.watch(reviewCountProvider);

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.book_outlined),
        selectedIcon: const Icon(Icons.book),
        label: localization(context).dictionaryTitle,
      ),
      NavigationDestination(
        icon: _buildBadge(
          value: reviewCountStream,
          icon: Icon(Icons.repeat_outlined),
        ),
        selectedIcon: const Icon(Icons.repeat),
        label: localization(context).repeatTitle,
      ),
    ];

    final currentIndex = navigationShell.currentIndex;

    final showFab = currentIndex == 0;

    return ScaffoldWithNavigation(
      destinations: destinations,
      selectedIndex: currentIndex,
      onDestinationSelected: (value) => navigationShell.goBranch(value),
      floatingActionButton: showFab ? _buildFab(context) : null,
      fabSlot: _buildFab(context, isSlot: true),
      fabExtendedSlot: _buildFab(context, isExtended: true, isSlot: true),
      body: navigationShell,
    );
  }

  void _openEditDialog(BuildContext context) async {
    await showResponsiveDialog(
      context: context,
      content: EditWordDialog(wordId: null),
    );
  }

  Widget _buildFab(
    BuildContext context, {
    bool isExtended = false,
    bool isSlot = false,
  }) {
    return isExtended
        ? FloatingActionButton.extended(
            onPressed: () => _openEditDialog(context),
            icon: const Icon(Icons.add),
            label: Text(localization(context).newWordTitle),
            elevation: isSlot ? 0 : null,
          )
        : FloatingActionButton(
            onPressed: () => _openEditDialog(context),
            elevation: isSlot ? 0 : null,
            child: const Icon(Icons.add),
          );
  }
}
 */

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
            context.push(Routes.editWord.withId(null));
          },
          child: const Icon(Icons.add),
        ),
        int() => null,
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
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final dictionary = data[index];
                            return ListTile(
                              title: Text(dictionary.name),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(24),
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
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CreateDictionaryDialog();
                              },
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
