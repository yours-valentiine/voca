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
