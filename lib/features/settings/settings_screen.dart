import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:voca/config/dependecies.dart';
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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        translations(
                          context,
                        ).settings.theme.dynamicColor.dialogTitle,
                      ),
                      content: MaterialPicker(
                        pickerColor: settings.color,
                        onColorChanged: (value) async =>
                            await notifier.setColor(value),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(translations(context).base.cancel),
                        ),
                      ],
                    ),
                  );
                },
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

  void _aboutVocaShow(BuildContext context) => showAboutDialog(
    context: context,
    applicationIcon: Image.asset("assets/icon/icon.png", height: 100, width: 100),
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
