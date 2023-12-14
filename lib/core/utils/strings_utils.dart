import 'dart:math';

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

String getRandomString(int length) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}
