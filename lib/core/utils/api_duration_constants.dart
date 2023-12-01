class ApiDurationConstants {
  // 300 запросов в минуту (5 in sec)
  // just in case make ~3 requests per minute
  static const Duration advertsDurationBetweenReqInMs =
      Duration(milliseconds: 300);
  static const Duration advertDurationBetweenReqInMs =
      Duration(milliseconds: 300);
  static const Duration startDurationBetweenReqInMs =
      Duration(milliseconds: 300);
  static const Duration pauseDurationBetweenReqInMs =
      Duration(milliseconds: 300);

  static const Duration cpmDurationBetweenReqInMs = Duration(milliseconds: 300);

  // 240 запросов в минуту (4 in sec)
  // just in case make 2 requests per minute
  static const Duration budgetDurationBetweenReqInMs =
      Duration(milliseconds: 500);
  static const Duration wordsDurationBetweenReqInMs =
      Duration(milliseconds: 500);
  // 60 запросов в минуту (1 in sec)
  static const Duration balanceDurationBetweenReqInMs =
      Duration(milliseconds: 1000);

  // 10 запросов в минуту (1 in 6 sec)
  // just in case make 1 request per 10 sec
  static const Duration autoStatNumsDurationBetweenReqInMs = Duration(
    milliseconds: 10000,
  );
  static const Duration autoStatWordsNumsDurationBetweenReqInMs = Duration(
    milliseconds: 10000,
  );
  static const Duration fullStatNumsDurationBetweenReqInMs = Duration(
    milliseconds: 10000,
  );

  static const Duration autoSetExcludedDurationBetweenReqInMs = Duration(
    milliseconds: 10000,
  );

  static Future<void> ready(DateTime? lastReq, Duration duration) async {
    if (lastReq == null) {
      return;
    }
    while (DateTime.now().difference(lastReq) < duration) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return;
  }
}
