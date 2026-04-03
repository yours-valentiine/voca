// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// assets_model.dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'assets_model.g.dart';

@JsonSerializable()
class AssetsModel {
  final String url;
  final int id;
  final String name;
  final String digest;
  @JsonKey(name: "browser_download_url")
  final String downloadUrl;

  const AssetsModel({
    required this.url,
    required this.id,
    required this.name,
    required this.digest,
    required this.downloadUrl,
  });

  factory AssetsModel.fromJson(Map<String, dynamic> json) =>
      _$AssetsModelFromJson(json);
  Map<String, dynamic> toJson() => _$AssetsModelToJson(this);
}
