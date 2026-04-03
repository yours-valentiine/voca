// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// settings_screen.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/i18n/strings.g.dart';
import 'package:voca/router/routes.dart';
import 'package:voca/shared/ui/widgets/material_switch.dart';
import 'package:voca/shared/util/context_helpers.dart';
import 'package:voca/shared/util/locale_helpers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.watch(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(translations(context).settings.title),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.translate_outlined),
            title: Text(translations(context).settings.language.title),
            subtitle: Text(settings.locale.toDisplay()),
            onTap: () async => await showChangeLanguageDialog(
              context,
              onLocaleChanged: (value) => notifier.setLocale(value),
              onConfirmTap: () async {
                final result = await notifier.saveLocale();
                if (context.mounted) {
                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Durations.extralong2,
                        content: Text(
                          translations(
                            context,
                          ).settings.language.change.message,
                        ),
                      ),
                    );
                  }
                  context.pop();
                }
              },
              onCancelTap: () {
                notifier.cancelUpdateLocale();
                context.pop();
              },
            ),
          ),
          const Divider(),
          SettingsSection(
            label: translations(context).settings.theme.title,
            children: [
              ListTile(
                leading: const Icon(Icons.color_lens_outlined),
                title: Text(
                  translations(context).settings.theme.dynamicColor.title,
                ),
                subtitle: Text(
                  translations(context).settings.theme.dynamicColor.description,
                ),
                trailing: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: settings.color,
                  ),
                ),
                onTap: () => showColorPickerDialog(
                  context,
                  onColorChanged: (value) async =>
                      await notifier.setColor(value),
                  onDoneTap: () => context.pop(),
                ),
              ),
            ],
          ),
          const Divider(),
          SettingsSection(
            label: translations(context).settings.backup.title,
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: Text(translations(context).settings.backup.export.title),
                subtitle: Text(
                  translations(context).settings.backup.export.description,
                ),
                onTap: () async =>
                    await _export(context, onFileLoad: notifier.exportData),
              ),
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: Text(translations(context).settings.backup.import.title),
                subtitle: Text(
                  translations(context).settings.backup.import.description,
                ),
                onTap: () async =>
                    await _import(context, onFileLoad: notifier.importData),
              ),
            ],
          ),
          const Divider(),
          SettingsSection(
            label: translations(context).settings.updates.title,
            children: [
              ListTile(
                leading: const Icon(Icons.science_outlined),
                title: Text(
                  translations(context).settings.updates.prerelease.title,
                ),
                subtitle: Text(
                  translations(context).settings.updates.prerelease.description,
                ),
                trailing: MaterialSwitch(
                  value: settings.allowPrerelease,
                  onChanged: (value) async {
                    if (value) {
                      await showAllowPrereleaseDialog(
                        value,
                        context,
                        onAllow: () async =>
                            await notifier.setAllowPrerelease(value),
                      );
                    } else {
                      await notifier.setAllowPrerelease(value);
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: Text(translations(context).settings.updates.check.title),
                subtitle: Text(
                  translations(context).settings.updates.check.description,
                ),
                onTap: () async {
                  final result = await notifier.checkLatest();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Durations.extralong2,
                        content: result == null
                            ? Text(
                                translations(
                                  context,
                                ).settings.updates.check.message.yourLatest,
                              )
                            : Text(
                                translations(context)
                                    .settings
                                    .updates
                                    .check
                                    .message
                                    .newVersion(version: result.version),
                              ),
                        action: result == null
                            ? null
                            : SnackBarAction(
                                label: translations(
                                  context,
                                ).settings.updates.check.message.update,
                                onPressed: () => context.go(
                                  Routes.updating.location,
                                  extra: result,
                                ),
                              ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const Divider(),
          SettingsSection(
            label: translations(context).settings.other.title,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(translations(context).settings.other.about.title),
                onTap: () => _aboutVocaShow(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> showAllowPrereleaseDialog(
    bool value,
    BuildContext context, {
    required VoidCallback onAllow,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translations(context).settings.updates.prerelease.title),
        content: Text.rich(
          translations(context).settings.updates.prerelease.warning(
            bold: (text) => TextSpan(
              text: text,
              style: typography(
                context,
              ).bodyMedium?.copyWith(fontWeight: .w700),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop(false);
            },
            child: Text(translations(context).base.cancel),
          ),
          TextButton(
            onPressed: () {
              context.pop(true);
            },
            child: Text(translations(context).base.confirm),
          ),
        ],
      ),
    );

    if (result ?? false) onAllow();
  }

  Future<void> showColorPickerDialog(
    BuildContext context, {
    required ValueChanged<Color> onColorChanged,
    required VoidCallback onDoneTap,
  }) => showDialog(
    context: context,
    builder: (context) => Consumer(
      builder: (context, ref, child) {
        final color = ref.watch(
          settingsNotifierProvider.select((s) => s.color),
        );
        return AlertDialog(
          title: Text(
            translations(context).settings.theme.dynamicColor.dialogTitle,
          ),
          content: MaterialPicker(
            pickerColor: color,
            onColorChanged: onColorChanged,
          ),
          actions: [
            TextButton(
              onPressed: onDoneTap,
              child: Text(translations(context).base.done),
            ),
          ],
        );
      },
    ),
  );

  Future<void> showChangeLanguageDialog(
    BuildContext context, {
    required ValueChanged<AppLocale> onLocaleChanged,
    required VoidCallback onConfirmTap,
    required VoidCallback onCancelTap,
  }) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(translations(context).settings.language.change.title),
      content: Consumer(
        builder: (context, ref, child) {
          final currentLocale = ref.watch(
            settingsNotifierProvider.select((s) => s.locale),
          );
          return SizedBox(
            width: 320,
            height: 240,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: AppLocale.values.length,
              itemBuilder: (context, index) {
                final tileLocale = AppLocale.values[index];
                return ListTile(
                  leading: currentLocale == tileLocale
                      ? const Icon(Icons.check)
                      : null,
                  title: Text(tileLocale.toDisplay()),
                  selected: currentLocale == tileLocale,
                  selectedTileColor: colorScheme(context).primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(18),
                  ),
                  onTap: () => onLocaleChanged(tileLocale),
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: onCancelTap,
          child: Text(translations(context).base.cancel),
        ),
        TextButton(
          onPressed: onConfirmTap,
          child: Text(translations(context).base.confirm),
        ),
      ],
    ),
  );

  void _aboutVocaShow(BuildContext context) => showAboutDialog(
    context: context,
    applicationIcon: Image.asset(
      "assets/icon/icon.png",
      height: 100,
      width: 100,
    ),
    applicationName: "Voca",
    applicationVersion: "v.0.1.0-alpha.1",
    applicationLegalese: "\u00a9 2026 yours.valentiine",
    children: [
      const SizedBox(height: 12),
      Text("Made with \u2764 and Flutter"),
    ],
  );

  Future<void> _export(
    BuildContext context, {
    required Future Function(String) onFileLoad,
  }) async {
    final out = await FilePicker.platform.saveFile(
      dialogTitle: translations(context).settings.backup.export.title,
      fileName: "backup.zip",
      type: .custom,
      allowedExtensions: ["zip"],
    );

    if (out == null) return;

    await onFileLoad(out);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: .horizontal,
          duration: Durations.long4,
          content: Text(translations(context).settings.backup.export.success),
          behavior: .floating,
        ),
      );
    }
  }

  Future<void> _import(
    BuildContext context, {
    required Future Function(String) onFileLoad,
  }) async {
    final file = await FilePicker.platform.pickFiles(
      type: .custom,
      allowedExtensions: ["zip"],
    );

    if (file == null) return;

    await onFileLoad(file.files.first.path!);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Durations.long4,
          behavior: .floating,
          content: Text(translations(context).settings.backup.import.success),
        ),
      );
    }
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.label,
    required this.children,
  });

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(label, style: typography(context).labelMedium),
        ),
        ...children,
      ],
    );
  }
}
