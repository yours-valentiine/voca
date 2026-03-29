// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// repeat_notifier.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voca/config/dependecies.dart';

part 'repeat_notifier.freezed.dart';

final repeatStaticsProvider = StreamProvider<RepeatStatics>((ref) {
  final currentDictionary = ref.watch(currentDictionaryNotifierProvider);
  final fsrsRepository = ref.watch(fsrsRepositoryProvider);

  return currentDictionary.maybeWhen(
    data: (data) => Rx.combineLatest2(
      fsrsRepository.watchCount(data.dictionaryId),
      fsrsRepository.watchNewCount(data.dictionaryId),
      (allCount, newCount) =>
          RepeatStatics(allCount: allCount, newCount: newCount),
    ),
    orElse: () => Stream.value(RepeatStatics(allCount: 0, newCount: 0)),
  );
});

@freezed
class RepeatStatics with _$RepeatStatics {
  RepeatStatics({required this.allCount, required this.newCount});

  final int allCount;
  final int newCount;

  int get duration =>
      ((newCount * 60 + (allCount - newCount) * 30) / 60).ceil();
}
