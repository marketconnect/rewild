String nowDateTimeIso8601String() {
  return DateTime.now().toIso8601String();
}

DateTime fromIso8601String(String iso8601String) {
  return DateTime.parse(iso8601String);
}

DateTime yesterdayEndOfTheDay() {
  // yesterday 23:59:55
  DateTime now = DateTime.now();

  final dateFrom = now.subtract(Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second + 5,
      milliseconds: now.millisecond,
      microseconds: now.microsecond));
  return dateFrom;
}

Future<void> justWait({required int numberOfSeconds}) async {
  await Future.delayed(Duration(seconds: numberOfSeconds));
}

DateTime getStartOfDay(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

DateTime getEndOfDay(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
}
