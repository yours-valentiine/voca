import 'package:uuid/uuid.dart';

UuidValue generateUuid() => UuidValue.fromString(Uuid().v7());