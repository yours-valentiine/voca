enum Routes {
  dictionary("/dictionary"),
  editDictionary("/edit-dictionary"),
  exercises("/exercises"),
  word("/word"),
  editWord("/edit-word"),
  spacedRepetition("/spaced-repetition"),
  settings("/settings");

  final String location;

  const Routes(this.location);
}

extension RoutesHelper on Routes {
  String withId(Object? id) => location.replaceFirst(":id", id.toString());
}
