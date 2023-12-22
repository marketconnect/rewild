String toIso8601StringNow() {
  return DateTime.now().toIso8601String();
}

DateTime fromIso8601String(String iso8601String) {
  return DateTime.tryParse(iso8601String) ?? DateTime.now();
}

int getMonthAgoTimestamp() {
  DateTime nowDate = DateTime.now();
  DateTime monthAgo = DateTime(nowDate.year, nowDate.month - 1, nowDate.day,
      nowDate.hour, nowDate.minute, nowDate.second);
  return monthAgo.millisecondsSinceEpoch ~/ 1000;
}

int getNowTimestamp() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

DateTime yesterdayEndOfTheDay() {
  DateTime now = DateTime.now();

  final dateFrom = now.subtract(Duration(
    hours: now.hour,
    minutes: now.minute,
    seconds: now.second + 5,
    milliseconds: now.millisecond,
    microseconds: now.microsecond,
  ));
  return dateFrom;
}

String formatReviewDate(DateTime createdAt) {
  return DateTime.now().day == createdAt.day
      ? '${createdAt.toLocal().hour.toString().padLeft(2, '0')}:${createdAt.toLocal().minute.toString().padLeft(2, '0')}'
      : '${createdAt.day}.${createdAt.month}.${createdAt.year}';
}
