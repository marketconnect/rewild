String nowDateTimeIso8601String() {
  return DateTime.now().toIso8601String();
}

bool isIntraday(DateTime date) {
  DateTime now = DateTime.now();

  // Compare the year, month, and day
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    // Check if the given date is between the start and end of the day
    if (date.isAfter(DateTime(now.year, now.month, now.day)) &&
        date.isBefore(DateTime(now.year, now.month, now.day + 1))) {
      return true;
    }
  }

  return false;
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

String formatDateTime(DateTime dateTime) {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
  DateTime dayBeforeYesterday = DateTime(now.year, now.month, now.day - 2);

  if (dateTime.isAfter(today)) {
    // If the DateTime is today, return the time in hh:mm format
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  } else if (dateTime.isAfter(yesterday)) {
    // If the DateTime is yesterday, return 'yesterday'
    return 'Вчера';
  } else if (dateTime.isAfter(dayBeforeYesterday)) {
    // If the DateTime is the day before yesterday, return '2 days ago'
    return '2 дня назад';
  } else {
    // For any other date, return the date in yyyy-MM-dd format
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
  }
}

DateTime getMidnight(DateTime date) {
  return DateTime(date.year, date.month, date.day, 0, 1);
}
