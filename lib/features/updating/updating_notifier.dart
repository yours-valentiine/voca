// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:voca/config/dependecies.dart';
import 'package:voca/shared/service/updater/models/version_model.dart';
import 'package:voca/shared/service/updater/updater_service.dart';

part 'updating_notifier.freezed.dart';

class UpdatingNotifier extends Notifier<UpdatingState> {
  late final UpdaterService _updaterService = ref.watch(updaterServiceProvider);

  final VersionModel model;

  UpdatingNotifier(this.model);

  @override
  UpdatingState build() {
    return .started();
  }

  Future<void> downloadLatest() async {
    try {
      await state.maybeWhen(
        started: () async {
          final updater = await _updaterService.downloadVersion(
            model,
            onReceiveProgress: (count, total) => state = .downloading(
              total: total / 1024 / 1024,
              count: count / 1024 / 1024,
            ),
          );
          state = .ready(file: updater);
        },
        orElse: () {},
      );

      await Future.delayed(Duration(seconds: 10));
      await install();
    } catch (error) {
      state = .error(error: error as Exception);
    }
  }

  Future<void> abortInstall() async {
    try {
      await state.maybeWhen(
        ready: (file) async => await _updaterService.clearDownloading(file),
        orElse: () {},
      );
    } catch (err) {
      state = .error(error: err as Exception);
    }
  }

  Future<void> install() async {
    try {
      state.maybeWhen(
        ready: (file) async => await _updaterService.installVersion(file),
        orElse: () {},
      );
    } catch (error) {
      state = .error(error: error as Exception);
    }
  }
}

@freezed
sealed class UpdatingState with _$UpdatingState {
  const factory UpdatingState.started() = _$Started;

  const factory UpdatingState.downloading({
    required double total,
    required double count,
  }) = _$Installing;

  const factory UpdatingState.ready({required File file}) = _$Ready;

  const factory UpdatingState.error({required Exception error}) = _$Error;
}
