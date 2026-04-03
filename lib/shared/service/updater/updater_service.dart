// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// updater_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:apk_sideload/install_apk.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:version/version.dart';
import 'package:voca/shared/error/service_errors.dart';
import 'package:voca/shared/service/updater/models/assets_model.dart';
import 'package:voca/shared/service/updater/models/version_model.dart';
import 'package:voca/shared/service/preferences/voca_preferences.dart';

class UpdaterService {
  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(minutes: 1),
      receiveTimeout: const Duration(minutes: 2),
      headers: {"User-Agent": "VocaApplication"},
      responseType: .json,
    ),
  );

  static const String _baseUrl =
      "https://api.github.com/repos/yours-valentiine/voca";
  static const String _prerelasesUrl = "/releases";
  static const String _realeseUrl = "/releases/latest";
  static const String _updatePath = "update_info.json";

  final VocaSettings settings;

  UpdaterService({required this.settings});

  Future<VersionModel?> checkUpdate({bool? showPrerelease}) async {
    final lastTime = settings.getDateCheckUpdate;
    final supportDirectory = await getApplicationSupportDirectory();
    final updateInfoFile = File("${supportDirectory.path}/$_updatePath");

    if (lastTime != null &&
        DateTime.timestamp().difference(lastTime) < Duration(hours: 6)) {
      if (!await updateInfoFile.exists()) return null;

      final updateInfo = VersionModel.fromJson(
        jsonDecode(await updateInfoFile.readAsString()),
      );
      return updateInfo;
    }

    final latestUpdate = switch (showPrerelease) {
      true => await _checkUpdatePrerelease(),
      _ => await _checkUpdateLatest(),
    };

    if (latestUpdate == null) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = Version.parse(packageInfo.version);
    final latestVersion = Version.parse(
      latestUpdate.version.replaceFirst('v', ''),
    );

    if (latestVersion.compareTo(currentVersion) == 1) {
      if (!await updateInfoFile.exists()) await updateInfoFile.create();

      await updateInfoFile.writeAsString(jsonEncode(latestUpdate.toJson()));
      return latestUpdate;
    }

    return null;
  }

  Future<VersionModel?> _checkUpdatePrerelease() async {
    final response = await _dio.get("$_baseUrl$_prerelasesUrl");

    if (response.statusCode == 200 && response.data != null) {
      final jsonList = response.data as List<dynamic>;
      final versions = jsonList
          .map((json) => VersionModel.fromJson(json))
          .toList();

      final latestRealese = versions.lastOrNull;

      if (latestRealese == null) return null;

      return latestRealese;
    }

    return null;
  }

  Future<VersionModel?> _checkUpdateLatest() async {
    final response = await _dio.get("$_baseUrl$_realeseUrl");

    print(response.data.runtimeType);

    if (response.statusCode == HttpStatus.ok) {
      try {
        final version = VersionModel.fromJson(response.data);
        return version;
      } catch (error) {
        print(error);
        rethrow;
      }
    }
    return null;
  }

  Future<File> downloadVersion(
    VersionModel model, {
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final File updaterFile;
    final AssetsModel assetsPlatform;

    if (Platform.isAndroid) {
      final arch = await DeviceInfoPlugin().androidInfo;

      if (arch.supportedAbis.contains("arm64-v8a")) {
        assetsPlatform = model.assets.firstWhere(
          (a) => a.name.contains("android-arm64-v8a"),
        );
      } else if (arch.supportedAbis.contains("armeabi-v7a")) {
        assetsPlatform = model.assets.firstWhere(
          (a) => a.name.contains("android-armeabi-v7a"),
        );
      } else if (arch.supportedAbis.contains("x86_64")) {
        assetsPlatform = model.assets.firstWhere(
          (a) => a.name.contains("android-x86_64"),
        );
      } else {
        throw UnsupportedPlatformError(platform: Platform.operatingSystem);
      }

      updaterFile = File("${tempDir.path}/update.apk");
    } else if (Platform.isWindows) {
      assetsPlatform = model.assets.firstWhere(
        (a) => a.name.contains("windows"),
        orElse: () => throw Exception("Assets for platform not found"),
      );
      updaterFile = File("${tempDir.path}/update.exe");
    } else {
      throw UnsupportedPlatformError(
        platform: Platform.operatingSystem,
        stackTrace: StackTrace.current,
      );
    }

    if (await updaterFile.exists()) {
      await updaterFile.delete();
    }

    try {
      final response = await _dio.download(
        assetsPlatform.downloadUrl,
        updaterFile.path,
        onReceiveProgress: onReceiveProgress,
      );

      if (response.statusCode == 200) {
        final expectedHash = assetsPlatform.digest
            .split(':')
            .last
            .toLowerCase();
        final computedHash = await sha256.bind(updaterFile.openRead()).first;
        final computedHashStr = computedHash.toString();

        if (expectedHash != computedHashStr) {
          throw HashVerificationError(
            expected: expectedHash,
            computed: computedHash.toString(),
            stackTrace: StackTrace.current,
          );
        }

        return updaterFile;
      }

      throw HttpFailedError(
        statusCode: response.statusCode ?? 502,
        statusMessage: response.statusMessage ?? "Something went wrong",
        stackTrace: StackTrace.current,
      );
    } catch (error) {
      if (await updaterFile.exists()) {
        await updaterFile.delete();
      }
      rethrow;
    }
  }

  Future<void> installVersion(File file) async {
    if (!await file.exists()) return;

    if (Platform.isAndroid) {
      await InstallApk().installApk(file.path);
    } else if (Platform.isWindows) {
      Process.start(file.path, []);
    } else {
      throw UnsupportedPlatformError(platform: Platform.operatingSystem);
    }
  }

  Future<void> clearDownloading(File file) async {
    await file.delete(recursive: true);
  }
}
