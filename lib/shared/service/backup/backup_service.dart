// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// backup_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:uuid/parsing.dart';
import 'package:voca/shared/service/backup/models/backup_dictionary.dart';
import 'package:voca/shared/service/backup/models/backup_fsrs.dart';
import 'package:voca/shared/service/backup/models/backup_metadata.dart';
import 'package:voca/shared/service/backup/models/backup_translate.dart';
import 'package:voca/shared/service/backup/models/backup_word.dart';
import 'package:voca/data/local/database.dart';
import 'package:voca/data/repository/dictionary_repository.dart';

class BackupService {
  // #region Constants

  static const String _tempPrefix = "voca_tmp_";

  // #endregion

  // #region DI classes

  final VocaDatabase vocaDatabase;
  final DictionaryRepository dictionaryRepository;

  //#endregion

  BackupService({
    required this.dictionaryRepository,
    required this.vocaDatabase,
  });

  Future<File> createExport({required List<BackupTables> tables}) async {
    final temp = await Directory.systemTemp.createTemp(_tempPrefix);
    final exportDir = Directory("${temp.path}/export");
    await exportDir.create(recursive: true);

    try {
      for (final table in tables) {
        final exportingData = await _getTableData(table);

        final jsonFile = File("${exportDir.path}/${table.name}.json");
        await jsonFile.writeAsString(jsonEncode(exportingData));
      }

      final metadata = BackupMetadata(
        version: 1,
        exportDate: DateTime.now().toIso8601String(),
        appVersion: "1.0.0-dev.1",
      );

      final metadataFile = File("${exportDir.path}/metadata.json");
      await metadataFile.writeAsString(jsonEncode(metadata.toJson()));

      final zipFile = File(
        "${temp.path}/backup_${DateTime.timestamp().millisecondsSinceEpoch}.zip",
      );
      final encoder = ZipFileEncoder()..create(zipFile.path);

      final files = await exportDir.list().toList();

      for (final file in files.whereType<File>()) {
        await encoder.addFile(file, file.path.split('/').last);
      }
      await encoder.close();

      return zipFile;
    } finally {
      await exportDir.delete(recursive: true);
    }
  }

  Future<List<Map<String, dynamic>>> _getTableData(BackupTables table) async =>
      switch (table) {
        BackupTables.dictionary =>
          (await vocaDatabase.dictionaryDao.getAll())
              .map(
                (d) => BackupDictionary(
                  dictionaryId: UuidParsing.unparse(d.dictionaryId),
                  name: d.name,
                  updatedAt: d.updatedAt.millisecondsSinceEpoch,
                ).toJson(),
              )
              .toList(),
        BackupTables.word =>
          (await vocaDatabase.wordDao.getAll())
              .map(
                (w) => BackupWord(
                  wordId: UuidParsing.unparse(w.wordId),
                  word: w.word,
                  transcription: w.transcription,
                  note: w.note,
                  dictionaryId: UuidParsing.unparse(w.dictionaryId),
                  updatedAt: w.updatedAt.millisecondsSinceEpoch,
                ).toJson(),
              )
              .toList(),
        BackupTables.translate =>
          (await vocaDatabase.translateDao.getAll())
              .map(
                (t) => BackupTranslate(
                  translateId: UuidParsing.unparse(t.translateId),
                  translate: t.translate,
                  position: t.position,
                  wordId: UuidParsing.unparse(t.wordId),
                  updatedAt: t.updatedAt.millisecondsSinceEpoch,
                ).toJson(),
              )
              .toList(),
        BackupTables.fsrs =>
          (await vocaDatabase.fsrsDao.getAll())
              .map(
                (f) => BackupFsrs(
                  wordId: UuidParsing.unparse(f.wordId),
                  state: f.state.value,
                  step: f.step,
                  stability: f.stability,
                  difficulty: f.difficulty,
                  due: f.due.millisecondsSinceEpoch,
                  lastReview: f.lastReview?.millisecondsSinceEpoch,
                ).toJson(),
              )
              .toList(),
      };

  Future<void> importData({required String backupPath}) async {
    final backupFile = File(backupPath);
    if (!(await backupFile.exists()) || backupPath.split('.').last != "zip") {
      return;
    }

    final tmp = await Directory.systemTemp.createTemp(_tempPrefix);
    final backupTmpArchive = await backupFile.copy("${tmp.path}/import.zip");

    try {
      final inputStream = InputFileStream(backupTmpArchive.path);
      final archive = ZipDecoder().decodeStream(inputStream);
      await extractArchiveToDisk(archive, "${tmp.path}/import");
      final unarchivedData = Directory("${tmp.path}/import/export");

      await vocaDatabase.attachedDatabase.transaction(() async {
        for (final table in BackupTables.values) {
          final fileTable = File("${unarchivedData.path}/${table.name}.json");

          if (!(await fileTable.exists())) {
            throw Exception("File for table $table not found");
          }

          final List<dynamic> jsonList = jsonDecode(
            await fileTable.readAsString(),
          );

          _importToTable(table, jsonList);
        }
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> _importToTable(
    BackupTables table,
    List<dynamic> jsonList,
  ) async {
    await vocaDatabase.batch((b) async {
      switch (table) {
        case BackupTables.dictionary:
          final data = jsonList
              .map((json) => BackupDictionary.fromJson(json).toModel())
              .toList();
          b.insertAllOnConflictUpdate(vocaDatabase.dictionaryEntity, data);
          break;

        case BackupTables.word:
          final data = jsonList
              .map((json) => BackupWord.fromJson(json).toModel())
              .toList();
          b.insertAllOnConflictUpdate(vocaDatabase.wordEntity, data);
          break;

        case BackupTables.translate:
          final data = jsonList
              .map((json) => BackupTranslate.fromJson(json).toModel())
              .toList();
          b.insertAllOnConflictUpdate(vocaDatabase.translateEntity, data);
          break;

        case BackupTables.fsrs:
          final data = jsonList
              .map((json) => BackupFsrs.fromJson(json).toModel())
              .toList();
          b.insertAllOnConflictUpdate(vocaDatabase.fsrsEntity, data);
          break;
      }
    });
  }

  /* Future<void> _importWithStrategic<E extends Table, D>(
    List<dynamic> jsonList,
    ImportStrategic strategic,
    TableInfo<E, D> table,
    Insertable<D> Function(dynamic) toModel, {
    Expression<bool> Function(E old, E excluded)? merge,
    List<Column>? target = const [],
    bool useInsertAllOnConflictUpdate = false,
  }) async {
    await vocaDatabase.batch((b) async {
      final data = jsonList.map(toModel).toList();

      switch (strategic) {
        case ImportStrategic.merge:
          for (final row in data) {
            b.insert(
              table,
              row,
              onConflict: DoUpdate.withExcluded(
                (E old, E excluded) => row,
                target: target,
                where: merge,
              ),
            );
          }
        case ImportStrategic.replace:
          b.insertAll(table, data, mode: .insertOrReplace);
        case ImportStrategic.skip:
          b.insertAll(table, data, mode: .insertOrIgnore);
      }
    });
  } */
}

enum BackupTables { dictionary, word, translate, fsrs }
