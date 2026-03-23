import 'package:flutter/material.dart';
import 'package:voca/shared/ui/theme/spacing.dart';
import 'package:voca/shared/util/context_helpers.dart';

abstract class MaterialNavigationRailTheme {
  static const double materialMinWithRail = 92.0;

  static const double materialMinExtendedRail = 220.0;

  static const double horizontalPadding = 20.0;
}

class AdaptiveNavigationRail extends StatefulWidget {
  const AdaptiveNavigationRail({
    super.key,
    this.leading,
    this.fabSlot,
    this.fabExtendedSlot,
    this.selectedIndex = 0,
    required this.destinations,
    this.onDestinationSelected,
  }) : assert(destinations.length <= 2),
       assert(selectedIndex <= destinations.length);

  final Widget? leading;
  final Widget? fabSlot;
  final Widget? fabExtendedSlot;

  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final void Function(int value)? onDestinationSelected;

  @override
  State<AdaptiveNavigationRail> createState() => _AdaptiveNavigationRailState();
}

class _AdaptiveNavigationRailState extends State<AdaptiveNavigationRail> {
  bool get hasFab => widget.fabSlot != null;

  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = colorScheme(context).surfaceContainer;

    return AnimatedContainer(
      duration: Durations.medium2,
      curve: Curves.linearToEaseOut,
      width: isOpen
          ? MaterialNavigationRailTheme.materialMinExtendedRail
          : MaterialNavigationRailTheme.materialMinWithRail,
      child: NavigationRail(
        extended: isOpen,
        backgroundColor: backgroundColor,
        labelType: isOpen ? null : .selected,
        leading: Padding(
          padding: const EdgeInsets.only(bottom: Spacings.M),
          child: Column(
            crossAxisAlignment: .center,
            spacing: Spacings.XS,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  isOpen = !isOpen;
                }),
                icon: isOpen
                    ? const Icon(Icons.menu_open)
                    : const Icon(Icons.menu),
              ),
              hasFab && isOpen
                  ? widget.fabExtendedSlot ?? widget.fabSlot!
                  : widget.fabSlot!,
            ],
          ),
        ),
        destinations: destinationsToRail(widget.destinations),
        selectedIndex: widget.selectedIndex,
        minWidth: MaterialNavigationRailTheme.materialMinWithRail,
        minExtendedWidth: MaterialNavigationRailTheme.materialMinExtendedRail,
        onDestinationSelected: widget.onDestinationSelected,
      ),
    );
  }
}

List<NavigationRailDestination> destinationsToRail(
  List<NavigationDestination> destinations,
) {
  return destinations.map((destination) {
    return NavigationRailDestination(
      icon: destination.icon,
      label: Text(destination.label),
      selectedIcon: destination.selectedIcon,
    );
  }).toList();
}
