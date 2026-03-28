import 'package:json_annotation/json_annotation.dart';

part 'backup_metadata.g.dart';

@JsonSerializable()
class BackupMetadata {
  final int version;
  final String exportDate;
  final String appVersion;

  const BackupMetadata({
    required this.version,
    required this.exportDate,
    required this.appVersion,
  });

  factory BackupMetadata.fromJson(Map<String, dynamic> json) =>
      _$BackupMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$BackupMetadataToJson(this);
}
