// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

// routes.dart
enum Routes {
  dictionary("/dictionary"),
  editDictionary("/edit-dictionary"),
  exercises("/exercises"),
  word("/word"),
  editWord("/edit-word"),
  spacedRepetition("/spaced-repetition"),
  settings("/settings"),
  updating("/updating");

  final String location;

  const Routes(this.location);
}

extension RoutesHelper on Routes {
  String withId(Object? id) => location.replaceFirst(":id", id.toString());
}
