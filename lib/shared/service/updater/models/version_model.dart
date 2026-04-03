// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// version_model.dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

import 'package:voca/shared/service/updater/models/assets_model.dart';

part 'version_model.g.dart';

@JsonSerializable()
class VersionModel {
  final String url;
  final int id;
  @JsonKey(name: "tag_name")
  final String version;
  final bool prerelease;
  final List<AssetsModel> assets;
  final String body;

  const VersionModel({
    required this.url,
    required this.id,
    required this.version,
    required this.assets,
    required this.body,
    required this.prerelease,
  });

  factory VersionModel.fromJson(Map<String, dynamic> json) =>
      _$VersionModelFromJson(json);
  Map<String, dynamic> toJson() => _$VersionModelToJson(this);
}
