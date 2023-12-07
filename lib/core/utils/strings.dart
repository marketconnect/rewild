extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return '';
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String take(int nbChars) => substring(0, nbChars.clamp(0, length));

  bool isWildberriesDetailUrl() {
    final regex =
        RegExp(r'^https:\/\/www\.wildberries\.ru\/catalog\/\d+\/detail\.aspx');
    return regex.hasMatch(this);
  }
}

String getNoun(int number, String one, String two, String five) {
  int n = number.abs() % 100;

  if (n >= 5 && n <= 20) {
    return five;
  }

  n %= 10;

  if (n == 1) {
    return one;
  }

  if (n >= 2 && n <= 4) {
    return two;
  }

  return five;
}
