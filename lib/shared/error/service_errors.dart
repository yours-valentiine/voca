// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// service_errors.dart
sealed class ServiceError implements Exception {
  final String message;
  final StackTrace? stackTrace;

  ServiceError({required this.message, this.stackTrace});
}

class UnsupportedPlatformError extends ServiceError {
  final String platform;

  UnsupportedPlatformError({required this.platform, super.stackTrace})
    : super(message: "Platform $platform is not supported");
}

class HttpFailedError extends ServiceError {
  final int statusCode;
  final String statusMessage;

  HttpFailedError({
    required this.statusCode,
    required this.statusMessage,
    super.stackTrace,
  }) : super(message: "HTTP failed:\n$statusCode:\t$statusMessage");
}

class HashVerificationError extends ServiceError {
  final String expected;
  final String computed;

  HashVerificationError({
    required this.expected,
    required this.computed,
    super.stackTrace,
  }) : super(
         message:
             "Hash verification failed:\nExpected: $expected\nGot: $computed",
       );
}
