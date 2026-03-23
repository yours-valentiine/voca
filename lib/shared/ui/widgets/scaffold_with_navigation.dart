import 'package:flutter/material.dart';
import 'package:voca/shared/ui/theme/spacing.dart';
import 'package:voca/shared/ui/widgets/adaptive_navigation_rail.dart';
import 'package:voca/shared/util/context_helpers.dart';
import 'package:voca/shared/util/window_size.dart';

class ScaffoldWithNavigation extends StatelessWidget {
  const ScaffoldWithNavigation({
    super.key,
    this.floatingActionButton,
    required this.destinations,
    this.selectedIndex = 0,
    required this.onDestinationSelected,
    this.trailing,
    this.fabSlot,
    this.fabExtendedSlot,
    required this.body,
  });

  final Widget? floatingActionButton;

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final void Function(int index) onDestinationSelected;

  final Widget? trailing;
  final Widget? fabSlot;
  final Widget? fabExtendedSlot;

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final windowSize = WindowSize.of(context);
    bool showFab =
        floatingActionButton != null &&
        (windowSize.isCompact || fabSlot == null);

    return Scaffold(
      drawer: Drawer(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 2,
          itemBuilder: (context, index) =>
              ListTile(title: Text("Title $index")),
        ),
      ),
      backgroundColor: windowSize.isCompact
          ? colorScheme(context).surface
          : colorScheme(context).surfaceContainer,
      floatingActionButton: showFab ? floatingActionButton : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              if (!windowSize.isCompact)
                AdaptiveNavigationRail(
                  destinations: destinations,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  fabSlot: fabSlot,
                  fabExtendedSlot: fabExtendedSlot,
                ),
              Expanded(
                child: switch (windowSize) {
                  .compact => body,
                  _ => Padding(
                    padding: const EdgeInsets.all(Spacings.M),
                    child: body,
                  ),
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: windowSize.isCompact
          ? NavigationBar(
              labelBehavior: .onlyShowSelected,
              destinations: destinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            )
          : SizedBox.shrink(),
    );
  }
}

@immutable
class AdaptiveNavigationDestination {
  final Widget icon;
  final Widget? selectedIcon;
  final String label;

  const AdaptiveNavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });
}
