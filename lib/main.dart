import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voca/config/dependecies.dart';
import 'package:voca/i18n/strings.g.dart';
import 'package:voca/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  final container = ProviderContainer();
  await container.read(vocaSettingsProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(child: VocaApp()),
    ),
  );
}

class VocaApp extends ConsumerWidget {
  const VocaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: "Voca",
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ref.watch(settingsNotifierProvider).color,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
