enum Routes {
  dictionary("/dictionary"),
  exercises("/exercises"),
  word("/word/:id"),
  editWord("/edit-word/:id"),
  spacedRepetition("/spaced-repetition"),
  settings("/settings");

  final String location;

  const Routes(this.location);
}

extension RoutesHelper on Routes {
  String withId(Object? id) => location.replaceFirst(":id", id.toString());
}
