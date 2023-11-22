extension ListExtension on List {
  List unique() {
    if (length == 0) {
      return this;
    }
    return toSet().toList();
  }
}
