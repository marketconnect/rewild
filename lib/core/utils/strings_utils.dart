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
