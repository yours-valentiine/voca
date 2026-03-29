// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// object_helper.dart
extension ObjectHelperNullable<T> on T? {
  bool get isNotNull => this != null;
  bool get isNull => this == null;

  T orElse(T Function() block) {
    return this ?? block();
  }

  R? let<R>(R Function(T value) block) => isNull ? null : block(this as T);
}

extension ObjectHelper<T> on T {
  R let<R>(R Function(T value) block) => block(this);
}
